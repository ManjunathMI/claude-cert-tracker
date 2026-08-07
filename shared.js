// Shared helpers used by both index.html (welcome page) and
// tracker.html (the board). Loaded after config.js on both pages.

function configIsSet(){
    return typeof SUPABASE_URL === 'string' &&
           typeof SUPABASE_ANON_KEY === 'string' &&
           !SUPABASE_URL.includes('YOUR_SUPABASE') &&
           !SUPABASE_ANON_KEY.includes('YOUR_SUPABASE');
  }
  
  function joinCodeIsSet(){
    return typeof JOIN_CODE_HASH === 'string' &&
           !JOIN_CODE_HASH.includes('PASTE_YOUR');
  }
  
  async function sha256Hex(text){
    const buf = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(text));
    return Array.from(new Uint8Array(buf)).map(x => x.toString(16).padStart(2,'0')).join('');
  }
  
  async function sbSelect(table, params){
    const url = `${SUPABASE_URL}/rest/v1/${table}?${params}`;
    const res = await fetch(url, { headers: { apikey: SUPABASE_ANON_KEY, Authorization: `Bearer ${SUPABASE_ANON_KEY}` } });
    if(!res.ok) throw new Error(`Supabase select failed: ${res.status}`);
    return res.json();
  }
  
  async function sbInsert(table, row){
    const url = `${SUPABASE_URL}/rest/v1/${table}`;
    const res = await fetch(url, {
      method: 'POST',
      headers: { apikey: SUPABASE_ANON_KEY, Authorization: `Bearer ${SUPABASE_ANON_KEY}`, 'Content-Type': 'application/json' },
      body: JSON.stringify(row)
    });
    if(!res.ok) throw new Error(`Supabase insert failed: ${res.status}`);
  }
  
  async function sbUpsert(table, row, onConflict){
    const url = `${SUPABASE_URL}/rest/v1/${table}?on_conflict=${onConflict}`;
    const res = await fetch(url, {
      method: 'POST',
      headers: { apikey: SUPABASE_ANON_KEY, Authorization: `Bearer ${SUPABASE_ANON_KEY}`, 'Content-Type': 'application/json', Prefer: 'resolution=merge-duplicates' },
      body: JSON.stringify(row)
    });
    if(!res.ok) throw new Error(`Supabase upsert failed: ${res.status}`);
  }
  
  // Calls the is_name_taken(room_code, name) Postgres function — see
  // supabase-setup.sql. Returns true/false without exposing the
  // pending queue's contents.
  async function isNameTaken(name){
    const url = `${SUPABASE_URL}/rest/v1/rpc/is_name_taken`;
    const res = await fetch(url, {
      method: 'POST',
      headers: { apikey: SUPABASE_ANON_KEY, Authorization: `Bearer ${SUPABASE_ANON_KEY}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({ p_room_code: ROOM_CODE, p_name: name })
    });
    if(!res.ok) throw new Error(`is_name_taken failed: ${res.status}`);
    return res.json();
  }
  
  // Calls check_learner_status(room_code, name) — returns one of
  // 'approved' | 'pending' | 'rejected' | 'unknown'.
  async function checkLearnerStatus(name){
    const url = `${SUPABASE_URL}/rest/v1/rpc/check_learner_status`;
    const res = await fetch(url, {
      method: 'POST',
      headers: { apikey: SUPABASE_ANON_KEY, Authorization: `Bearer ${SUPABASE_ANON_KEY}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({ p_room_code: ROOM_CODE, p_name: name })
    });
    if(!res.ok) throw new Error(`check_learner_status failed: ${res.status}`);
    return res.json();
  }
  
  // Local (non-Supabase) fallback storage, used only when config.js
  // hasn't been filled in yet — keeps the app usable for local testing
  // before a Supabase project exists.
  function localLoad(key, fallback){
    try{ const v = localStorage.getItem(key); return v ? JSON.parse(v) : fallback; }catch(e){ return fallback; }
  }
  function localSave(key, val){
    try{ localStorage.setItem(key, JSON.stringify(val)); }catch(e){}
  }