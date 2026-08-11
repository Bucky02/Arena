import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req) => {
  try {
    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Non autorizzato" }), {
        status: 401,
      });
    }

    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authHeader } } },
    );

    const {
      data: { user },
    } = await supabaseClient.auth.getUser();
    if (!user) {
      return new Response(JSON.stringify({ error: "Utente non trovato" }), {
        status: 401,
      });
    }

    // 1. Pulisce partite e giocatori_partita PRIMA di eliminare l'utente
    const { error: cleanupError } = await supabaseAdmin.rpc(
      "elimina_dati_utente",
      {
        p_id_utente: user.id,
      },
    );
    if (cleanupError) {
      return new Response(JSON.stringify({ error: cleanupError.message }), {
        status: 500,
      });
    }

    // 2. Ora elimina l'utente (CASCADE si occupa di 'utenti')
    const { error } = await supabaseAdmin.auth.admin.deleteUser(user.id);
    if (error) {
      return new Response(JSON.stringify({ error: error.message }), {
        status: 500,
      });
    }

    return new Response(JSON.stringify({ success: true }), { status: 200 });
  } catch (e) {
    return new Response(JSON.stringify({ error: e.message }), { status: 500 });
  }
});
