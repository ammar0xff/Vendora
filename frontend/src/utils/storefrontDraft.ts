import { useQuery } from '@tanstack/react-query'
import { settingsApi } from '../api/endpoints'

export const DRAFT_KEY = 'vendora-theme-draft'

export type StorefrontDraft = Record<string, unknown>

export function readThemeDraft(): StorefrontDraft | null {
  try {
    const raw = localStorage.getItem(DRAFT_KEY)
    return raw ? JSON.parse(raw) : null
  } catch {
    return null
  }
}

export function writeThemeDraft(draft: StorefrontDraft | null): void {
  try {
    if (draft) localStorage.setItem(DRAFT_KEY, JSON.stringify({ ...readThemeDraft(), ...draft }))
    else localStorage.removeItem(DRAFT_KEY)
  } catch {
    /* ignore */
  }
}

/** Saved settings merged over the unsaved draft — used by the storefront itself and admin previews. */
export function mergeSettings(saved: Record<string, unknown> | null | undefined) {
  const draft = readThemeDraft()
  if (!saved) return saved
  return { ...saved, ...(draft || {}) }
}

/** Settings = server rows + current unsaved draft (template, hero copy, theme). */
export function useMergedSettings() {
  const { data } = useQuery({ queryKey: ['settings'], queryFn: settingsApi.get, staleTime: 60_000, retry: false })
  return mergeSettings(data || {})
}

/* ------------------------------------------------------------------ */
/* Custom (imported WordPress-style) template — self-contained srcdoc   */
/* ------------------------------------------------------------------ */

export interface CustomThemeData {
  settings: Record<string, any>
  products: any[]
  categories: any[]
  posts: any[]
  menu: { label: string; href: string }[]
  socials: { name: string; href: string }[]
}

/**
 * Runtime injected into the imported template document. It makes the
 * template "fully dynamic": every {{token}} resolves live store data,
 * and repeat/mount hooks render products, categories, posts, menu and
 * socials from the store's own data.
 */
const CUSTOM_THEME_RUNTIME = `(function(){
  var D = window.__VENDORA__ || {};
  var S = D.settings || {};
  var CUR = S.currency || 'ج.م';

  function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
  function money(n){ var v = Number(n); if(isNaN(v)) return ''; return v.toLocaleString('en-US',{minimumFractionDigits:0, maximumFractionDigits:2}) + ' ' + CUR; }
  function token(ctx, key){
    if(!ctx) return S[key]==null?'':esc(S[key]);
    if(key.indexOf('.') > -1){
      var parts = key.split('.');
      var v = ctx;
      for(var i=0;i<parts.length && v!=null;i++) v = v[parts[i]];
      return v==null?'':esc(v);
    }
    var v = ctx[key];
    if(v==null || v==='') v = S[key];
    if(v==null || v==='') {
      if(key==='price') return money(S.retail_default);
      return '';
    }
    if(key==='retail_price'||key==='wholesale_price'||key==='price') return money(v);
    if(key==='image_url'&&v==='') return S.logo_url || '';
    return esc(v);
  }
  function isList(key){ return key==='products'||key==='categories'||key==='posts'; }
  function applyText(root, ctx){
    if(!root || !root.querySelectorAll) return;
    var walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT, null);
    var n, parts;
    while((n = walker.nextNode())){
      parts = n.nodeValue.split(/\\{\\{([^{}]+)\\}\\}/);
      if(parts.length > 1){
        for(var i=1;i<parts.length;i+=2){
          var t = token(ctx, parts[i].trim());
          if(t !== '') parts[i] = t;
        }
        n.nodeValue = parts.join('');
      }
    }
    var attrs = ['src','href','alt','title','placeholder'];
    for(var a=0;a<attrs.length;a++){
      var at = attrs[a];
      var els = root.querySelectorAll('['+at+'*="{{"]');
      for(var e=0;e<els.length;e++){
        var v = els[e].getAttribute(at);
        var m = v.replace(/\\{\\{([^{}]+)\\}\\}/g, function(_,k){ return token(ctx, k.trim()) || ''; });
        els[e].setAttribute(at, m);
      }
    }
  }
  function renderList(el){
    var key = el.getAttribute('data-vendora-repeat') || '';
    var arr = D[key] || [];
    var tpl = el.firstElementChild;
    if(!key || !tpl) return;
    if(!arr.length){ el.style.display='none'; return; }
    el.innerHTML = '';
    for(var i=0;i<arr.length;i++){
      var node = tpl.cloneNode(true);
      applyText(node, arr[i]);
      el.appendChild(node);
    }
  }
  function fillMount(el){
    var key = el.getAttribute('data-vendora-mount') || '';
    if(key==='none' || !D[key] || !D[key].length){ if(key==='products'&&(!D.products||!D.products.length)) el.style.display='none'; return; }
    var wrap = document.createElement('div');
    if(key==='products'){
      wrap.style.cssText = 'display:grid;grid-template-columns:repeat(auto-fill,minmax(160px,1fr));gap:14px;';
      D.products.forEach(function(p){
        var card = document.createElement('a');
        card.href = '/product/' + p.id;
        card.style.cssText = 'display:block;text-decoration:none;color:inherit;border:1px solid rgba(128,128,128,.25);border-radius:10px;overflow:hidden;background:transparent;';
        card.innerHTML = (p.image_url?'<img src="'+esc(p.image_url)+'" alt="" style="width:100%;height:130px;object-fit:cover;display:block;"/>':'<div style="height:130px;background:#f1f5f9;"></div>')
          + '<div style="padding:8px 10px;"><div style="font-size:12px;font-weight:700;line-height:1.3;">'+esc(p.name)+'</div>'
          + '<div style="font-size:11px;color:#94a3b8;">'+esc(p.company||'')+'</div>'
          + '<div style="font-size:13px;font-weight:800;margin-top:4px;">'+money(p.retail_price)+'</div></div>';
        wrap.appendChild(card);
      });
    } else if(key==='menu'){
      D.menu.forEach(function(m){
        var a = document.createElement('a');
        a.href = m.href || '#';
        a.rel = 'noopener';
        a.textContent = m.label || '';
        a.style.cssText = 'margin:0 8px;font-weight:700;';
        wrap.appendChild(a);
      });
    } else if(key==='socials'){
      D.socials.forEach(function(s){
        var a = document.createElement('a');
        a.href = s.href || '#';
        a.rel = 'noopener';
        a.textContent = s.name || '';
        a.style.cssText = 'display:inline-flex;align-items:center;justify-content:center;width:34px;height:34px;border-radius:50%;margin:0 4px;border:1px solid rgba(128,128,128,.35);font-size:12px;font-weight:700;text-decoration:none;color:inherit;';
        wrap.appendChild(a);
      });
    } else if(key==='categories'){
      wrap.style.cssText = 'display:grid;grid-template-columns:repeat(auto-fill,minmax(150px,1fr));gap:12px;';
      D.categories.forEach(function(c){
        var a = document.createElement('a');
        a.href = '/category/' + c.id;
        a.style.cssText = 'display:block;text-decoration:none;color:inherit;border:1px solid rgba(128,128,128,.25);border-radius:10px;padding:10px;background:transparent;';
        a.innerHTML = '<div style="font-size:13px;font-weight:700;">'+esc(c.name)+'</div><div style="font-size:11px;color:#94a3b8;">'+ (c.product_count||0) +' منتج</div>';
        wrap.appendChild(a);
      });
    } else if(key==='posts'){
      wrap.style.cssText = 'display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:14px;';
      D.posts.forEach(function(p){
        var a = document.createElement('a');
        a.href = p.href || '#';
        a.rel = 'noopener';
        a.style.cssText = 'display:block;text-decoration:none;color:inherit;border:1px solid rgba(128,128,128,.25);border-radius:10px;overflow:hidden;background:transparent;';
        a.innerHTML = (p.image_url?'<img src="'+esc(p.image_url)+'" alt="" style="width:100%;height:110px;object-fit:cover;display:block;"/>':'')
          + '<div style="padding:8px 10px;"><div style="font-size:12px;font-weight:700;line-height:1.3;">'+esc(p.title||'')+'</div>'
          + (p.excerpt?'<div style="font-size:11px;color:#94a3b8;margin-top:4px;">'+esc(p.excerpt)+'</div>':'')+'</div>';
        wrap.appendChild(a);
      });
    }
    el.innerHTML='';
    el.appendChild(wrap);
  }

  var repeats = document.querySelectorAll('[data-vendora-repeat]');
  for(var r=0;r<repeats.length;r++) renderList(repeats[r]);
  var mounts = document.querySelectorAll('[data-vendora-mount]');
  for(var g=0;g<mounts.length;g++) fillMount(mounts[g]);
  applyText(document.body, S);
  function bump(){ parent.postMessage({type:'vendora:height', height: document.documentElement.scrollHeight || document.body.scrollHeight}, '*'); }
  window.addEventListener('load', function(){ setTimeout(bump, 80); });
  if(window.ResizeObserver){ try{ new ResizeObserver(function(){ bump(); }).observe(document.body); }catch(e){} }
  document.addEventListener('click', function(e){
    var a = e.target && e.target.closest ? e.target.closest('a') : null;
    if(!a) return;
    var href = a.getAttribute('href') || '';
    if(href.charAt(0) !== '/') return;
    e.preventDefault();
    parent.postMessage({type:'vendora:nav', href: href}, '*');
  });
})();`

/**
 * Build a full self-contained document (for iframe srcdoc) from an imported
 * template. Live store data is injected as JSON + hydrated by the runtime.
 */
export function buildCustomThemeDoc(themeHtml: string, data: CustomThemeData): string {
  const safe = JSON.stringify(data).replace(/</g, '\\u003c')
  const CLOSE = '</scr' + 'ipt>'
  const scripts =
    `<script id="vendora-data" type="application/json">${safe}${CLOSE}` +
    `<script>\n${CUSTOM_THEME_RUNTIME}\n${CLOSE}`
  if (themeHtml.indexOf('</body>') !== -1) {
    return themeHtml.replace('</body>', scripts + '\n</body>')
  }
  return themeHtml + scripts
}