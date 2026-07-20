import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.7.1";
import Stripe from "https://esm.sh/stripe@13.6.0?target=deno";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY") ?? "", {
  apiVersion: "2023-10-16",
  httpClient: Stripe.createFetchHttpClient(),
});

serve(async (req) => {
  // Gestione CORS per chiamate esterne
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers":
          "authorization, x-client-info, apikey, content-type",
      },
    });
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
    );

    const body = await req.json().catch(() => ({}));
    const { stripe_customer_id } = body;
    if (!stripe_customer_id) throw new Error("stripe_customer_id mancante");

    const session = await stripe.billingPortal.sessions.create({
      customer: stripe_customer_id,
      return_url: "myapp://dashboard",
    });

    // Recuperiamo i dati della società
    const { data: societa, error } = await supabaseClient
      .from("societa")
      .select("*")
      .eq("id_utente", userId)
      .single();

    if (error || !societa) throw new Error("Società non trovata");

    let customerId = societa.stripe_customer_id;

    if (!customerId) {
      const customer = await stripe.customers.create({
        email: societa.email,
        name: societa.nome_societa,
      });
      customerId = customer.id;

      await supabaseClient
        .from("societa")
        .update({ stripe_customer_id: customerId })
        .eq("id", societa.id);
    }

    const session = await stripe.billingPortal.sessions.create({
      customer: customerId,
      return_url: "https://app.tuosito.it/dashboard",
    });

    return new Response(JSON.stringify({ url: session.url }), {
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
      status: 200,
    });
  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), {
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
      status: 400,
    });
  }
});
