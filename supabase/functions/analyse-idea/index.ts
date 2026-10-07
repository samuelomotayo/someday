import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import Anthropic from "https://esm.sh/@anthropic-ai/sdk@0.27.3";

const FREE_TIER_LIMIT = 3;

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "authorization, apikey, content-type",
      },
    });
  }

  try {
    // Authenticate the request using the user's JWT.
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return json({ error: "Missing authorization" }, 401);
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    const { data: { user }, error: authError } = await supabase.auth.getUser(
      authHeader.replace("Bearer ", ""),
    );

    if (authError || !user) {
      return json({ error: "Unauthorized" }, 401);
    }

    // Server-side usage enforcement — prevents paywall bypass.
    const { data: usage } = await supabase
      .from("user_analysis_usage")
      .select("count")
      .eq("user_id", user.id)
      .single();

    const currentCount = usage?.count ?? 0;
    if (currentCount >= FREE_TIER_LIMIT) {
      return json({ error: "Usage limit reached" }, 402);
    }

    // Parse the idea payload.
    const body = await req.json();
    const { ideaId, title, description, timePeriod, reasonForStopping, emotionalNote } = body;

    if (!title || !description) {
      return json({ error: "title and description are required" }, 400);
    }

    // Call the Claude API. Key lives ONLY in Edge Function secrets — never in client code.
    const anthropic = new Anthropic({
      apiKey: Deno.env.get("ANTHROPIC_API_KEY")!,
    });

    const systemPrompt = `You are the Someday Resurrection Engine. Your role is to give abandoned ideas an honest, generous second look.

Given an idea that was never launched, assess whether it deserves a second chance based on:
- Current market signals and timing
- Whether the original blockers (fear, self-doubt, circumstances) still apply
- The realistic effort required vs the opportunity

Respond with a JSON object with this exact structure:
{
  "verdict": "second_chance" | "sunset_confirmed" | "needs_more_context",
  "summary": "2-3 sentence honest, direct assessment",
  "confidence": 0.0-1.0,
  "signals": ["signal 1", "signal 2"] (only for second_chance),
  "reasons": ["reason 1", "reason 2"] (only for sunset_confirmed),
  "questions": ["question 1", "question 2"] (only for needs_more_context)
}

Voice: Steady. Honest. Generous. Never dismissive. Never falsely optimistic.`;

    const userPrompt = [
      `Title: ${title}`,
      `Description: ${description}`,
      timePeriod ? `When they worked on it: ${timePeriod}` : null,
      reasonForStopping ? `Why they stopped: ${reasonForStopping}` : null,
      emotionalNote ? `How they feel about it: ${emotionalNote}` : null,
    ]
      .filter(Boolean)
      .join("\n");

    const message = await anthropic.messages.create({
      model: "claude-opus-4-7",
      max_tokens: 1024,
      system: systemPrompt,
      messages: [{ role: "user", content: userPrompt }],
    });

    const responseText = (message.content[0] as { text: string }).text;
    let result: Record<string, unknown>;
    try {
      result = JSON.parse(responseText);
    } catch {
      return json({ error: "Failed to parse AI response" }, 500);
    }

    // Increment usage count on successful verdict.
    await supabase.rpc("increment_analysis_usage", { p_user_id: user.id });

    return json(result, 200);
  } catch (err) {
    console.error("analyse-idea error:", err);
    return json({ error: "Internal server error" }, 500);
  }
});

function json(body: unknown, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
    },
  });
}
