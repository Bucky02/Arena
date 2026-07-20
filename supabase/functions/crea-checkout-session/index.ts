import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import Stripe from "https://esm.sh/stripe?target=deno";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!, {
  apiVersion: "2023-10-16",
});

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "*",
      },
    });
  }

  try {
    const body = await req.json();
    const priceId = body.priceId;
    const customerId = body.customerId; // <--- AGGIUNGIAMO QUESTO

    if (!priceId) {
      return new Response(JSON.stringify({ error: "priceId mancante" }), {
        status: 400,
      });
    }

    // Creiamo un oggetto di configurazione dinamico
    const sessionConfig: any = {
      payment_method_types: ["card"],
      line_items: [{ price: priceId, quantity: 1 }],
      mode: "subscription",
      client_reference_id: priceId,
      success_url: `myapp://registrazione?piano=${body.piano}&session_id={CHECKOUT_SESSION_ID}&status=success`,
      cancel_url: "myapp://registrazione?status=cancel",
    };

    // SE L'UTENTE ESISTE GIÀ, ABBINIAMO IL SUO CUSTOMER ID EVITANDO DUPLICATI
    if (customerId) {
      sessionConfig.customer = customerId;
    }

    const session = await stripe.checkout.sessions.create(sessionConfig);

    return new Response(JSON.stringify({ url: session.url }), {
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
    });
  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
    });
  }
});
