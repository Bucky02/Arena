import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.7.1";
import Stripe from "https://esm.sh/stripe@13.6.0?target=deno";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY") ?? "", {
  apiVersion: "2023-10-16",
  httpClient: Stripe.createFetchHttpClient(),
});

// Funzione di utilità per mappare l'ID prezzo di Stripe con il nome piano e i limiti reali
function ottieniSpecifichePiano(priceId: string): {
  nome: string;
  limite: number;
} {
  // Sostituisci i codici 'price_...' con i reali ID Prezzo che trovi sulla Dashboard di Stripe
  switch (priceId) {
    case "price_1Th5bHFxZCOuiQIAaia7ASFn": // ID Prezzo del tuo piano Start
      return { nome: "START", limite: 1 };
    case "price_1TgjxqFxZCOuiQIA9CjLu34s": // ID Prezzo del tuo piano Pro
      return { nome: "PRO", limite: 2 };
    case "price_1Th5c2FxZCOuiQIAM6obraB0": // ID Prezzo del tuo piano Premium
      return { nome: "ENTERPRISE", limite: 4 };
    case "price_1Th5cRFxZCOuiQIA4VAKya37": // ID Prezzo del tuo piano Premium
      return { nome: "ELITE", limite: 5 };
    default:
      // Fallback sicuro se non riconosce il codice (almeno 1 campo lo lasciamo gestire)
      return { nome: "NESSUNO", limite: 0 };
  }
}

serve(async (req) => {
  const signature = req.headers.get("Stripe-Signature")!;
  const body = await req.text();
  let event;

  try {
    // DOPO
    event = await stripe.webhooks.constructEventAsync(
      body,
      signature,
      Deno.env.get("STRIPE_WEBHOOK_SECRET") ?? "",
    );
  } catch (err) {
    console.error(`Errore validazione Webhook: ${err.message}`);
    return new Response(`Webhook Error: ${err.message}`, { status: 400 });
  }

  const supabaseClient = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
  );

  console.log(`Evento Stripe intercettato: ${event.type}`);

  try {
    // ==========================================================
    // 1. PRIMO ACQUISTO (Checkout iniziale andato a buon fine)
    // ==========================================================
    if (event.type === "checkout.session.completed") {
      const session = event.data.object;

      // Recuperiamo i dettagli dell'abbonamento appena creato per sapere cosa ha comprato
      const subscription = await stripe.subscriptions.retrieve(
        session.subscription as string,
      );
      const priceId = subscription.items.data[0].price.id;

      const specifiche = ottieniSpecifichePiano(priceId);
      console.log(
        `CHECKOUT - priceId: ${priceId}, piano: ${specifiche.nome}, limite: ${specifiche.limite}`,
      ); // ← aggiungi questa riga

      console.log(
        `Nuovo abbonamento per cliente ${session.customer}. Piano: ${specifiche.nome}`,
      );
      console.log(`client_reference_id: ${session.client_reference_id}`);
      console.log(`customer: ${session.customer}`);

      await supabaseClient
        .from("societa")
        .update({
          piano_attuale: specifiche.nome,
          limite_campi: specifiche.limite,
          stripe_customer_id: session.customer, // Aggiorna o blinda il customer ID
        })
        .eq("id_utente", session.client_reference_id); // Assicurati che passi l'ID utente nel client_reference_id al checkout iniziale
    }

    // ==========================================================
    // 2. CAMBIO PIANO (Upgrade o Downgrade dal Portale Stripe)
    // ==========================================================
    if (event.type === "customer.subscription.updated") {
      const subscription = event.data.object;
      const priceId = subscription.items.data[0].price.id;

      const specifiche = ottieniSpecifichePiano(priceId);

      // Se l'utente ha annullato ma il periodo non è ancora finito, Stripe lo mette in 'active' con cancel_at_period_end = true
      // Se vuoi bloccarlo solo alla fine, gestisci lo stato normalmente
      if (
        subscription.status === "active" ||
        subscription.status === "trialing"
      ) {
        console.log(
          `Modifica abbonamento per cliente ${subscription.customer}. Nuovo Piano: ${specifiche.nome}`,
        );

        await supabaseClient
          .from("societa")
          .update({
            piano_attuale: specifiche.nome,
            limite_campi: specifiche.limite,
          })
          .eq("stripe_customer_id", subscription.customer);
      }
    }

    // ==========================================================
    // 3. ANNULLAMENTO DEFINITIVO (Abbonamento scaduto o cancellato)
    // ==========================================================
    if (event.type === "customer.subscription.deleted") {
      const subscription = event.data.object;

      console.log(
        `Abbonamento cancellato o scaduto per cliente ${subscription.customer}`,
      );

      await supabaseClient
        .from("societa")
        .update({
          piano_attuale: "NESSUNO", // Scriviamo "NESSUNO" o "START" (ma bloccato)
          limite_campi: 0, // <--- IMPOSTATO A 0 COME DISCI TU! Bloccato totalmente.
        })
        .eq("stripe_customer_id", subscription.customer);
    }
  } catch (error) {
    console.error(`Errore durante l'aggiornamento del DB Supabase:`, error);
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
    });
  }

  return new Response(JSON.stringify({ received: true }), { status: 200 });
});
