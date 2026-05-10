// icons.jsx — minimal hand-tuned icon set, monoline

const Icon = ({ name, size = 20, stroke = 'currentColor', fill = 'none', sw = 1.7, style }) => {
  const s = sw;
  const props = { width: size, height: size, viewBox: '0 0 24 24', fill, stroke, strokeWidth: s, strokeLinecap: 'round', strokeLinejoin: 'round', style };
  switch (name) {
    case 'cart': return <svg {...props}><path d="M3 4h2.4l2.2 11a2 2 0 0 0 2 1.6h7.6a2 2 0 0 0 2-1.6L21 7H6.5"/><circle cx="9.5" cy="20" r="1.4"/><circle cx="17.5" cy="20" r="1.4"/></svg>;
    case 'plus': return <svg {...props}><path d="M12 5v14M5 12h14"/></svg>;
    case 'minus': return <svg {...props}><path d="M5 12h14"/></svg>;
    case 'check': return <svg {...props}><path d="M5 12.5l4.5 4.5L19 7.5"/></svg>;
    case 'x': return <svg {...props}><path d="M6 6l12 12M18 6L6 18"/></svg>;
    case 'chev-r': return <svg {...props}><path d="M9 5l7 7-7 7"/></svg>;
    case 'chev-l': return <svg {...props}><path d="M15 5l-7 7 7 7"/></svg>;
    case 'chev-d': return <svg {...props}><path d="M5 9l7 7 7-7"/></svg>;
    case 'chev-u': return <svg {...props}><path d="M5 15l7-7 7 7"/></svg>;
    case 'more-h': return <svg {...props} fill={stroke} stroke="none"><circle cx="5" cy="12" r="1.6"/><circle cx="12" cy="12" r="1.6"/><circle cx="19" cy="12" r="1.6"/></svg>;
    case 'more-v': return <svg {...props} fill={stroke} stroke="none"><circle cx="12" cy="5" r="1.6"/><circle cx="12" cy="12" r="1.6"/><circle cx="12" cy="19" r="1.6"/></svg>;
    case 'gear': return <svg {...props}><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.7 1.7 0 0 0 .3 1.8l.1.1a2 2 0 1 1-2.8 2.8l-.1-.1a1.7 1.7 0 0 0-1.8-.3 1.7 1.7 0 0 0-1 1.5V21a2 2 0 1 1-4 0v-.1a1.7 1.7 0 0 0-1.1-1.5 1.7 1.7 0 0 0-1.8.3l-.1.1a2 2 0 1 1-2.8-2.8l.1-.1a1.7 1.7 0 0 0 .3-1.8 1.7 1.7 0 0 0-1.5-1H3a2 2 0 1 1 0-4h.1a1.7 1.7 0 0 0 1.5-1.1 1.7 1.7 0 0 0-.3-1.8l-.1-.1a2 2 0 1 1 2.8-2.8l.1.1a1.7 1.7 0 0 0 1.8.3H9a1.7 1.7 0 0 0 1-1.5V3a2 2 0 1 1 4 0v.1a1.7 1.7 0 0 0 1 1.5 1.7 1.7 0 0 0 1.8-.3l.1-.1a2 2 0 1 1 2.8 2.8l-.1.1a1.7 1.7 0 0 0-.3 1.8V9a1.7 1.7 0 0 0 1.5 1H21a2 2 0 1 1 0 4h-.1a1.7 1.7 0 0 0-1.5 1z"/></svg>;
    case 'home': return <svg {...props}><path d="M3 11l9-7 9 7v9a2 2 0 0 1-2 2h-4v-7h-6v7H5a2 2 0 0 1-2-2z"/></svg>;
    case 'list': return <svg {...props}><path d="M8 6h13M8 12h13M8 18h13"/><circle cx="3.5" cy="6" r="0.6" fill={stroke}/><circle cx="3.5" cy="12" r="0.6" fill={stroke}/><circle cx="3.5" cy="18" r="0.6" fill={stroke}/></svg>;
    case 'filter': return <svg {...props}><path d="M3 5h18M6 12h12M10 19h4"/></svg>;
    case 'image': return <svg {...props}><rect x="3" y="4" width="18" height="16" rx="2"/><circle cx="9" cy="10" r="1.5"/><path d="M3 16l5-4 4 3 3-2 6 5"/></svg>;
    case 'link': return <svg {...props}><path d="M10 14a4 4 0 0 0 5.7 0l3-3a4 4 0 0 0-5.7-5.7L11 7"/><path d="M14 10a4 4 0 0 0-5.7 0l-3 3a4 4 0 0 0 5.7 5.7L13 17"/></svg>;
    case 'paste': return <svg {...props}><rect x="8" y="3" width="8" height="4" rx="1"/><path d="M16 5h2a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V7a2 2 0 0 1 2-2h2"/></svg>;
    case 'export': return <svg {...props}><path d="M12 3v13M7 8l5-5 5 5M5 21h14"/></svg>;
    case 'camera': return <svg {...props}><path d="M4 7h3l2-3h6l2 3h3a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V9a2 2 0 0 1 2-2z"/><circle cx="12" cy="13" r="3.5"/></svg>;
    case 'pin': return <svg {...props}><path d="M12 21s7-7 7-12a7 7 0 1 0-14 0c0 5 7 12 7 12z"/><circle cx="12" cy="9" r="2.5"/></svg>;
    case 'pin-fill': return <svg {...props} fill={stroke}><path d="M12 22s7.5-7.4 7.5-12.5A7.5 7.5 0 0 0 4.5 9.5C4.5 14.6 12 22 12 22z"/><circle cx="12" cy="9.5" r="2.4" fill="#fff"/></svg>;
    case 'store': return <svg {...props}><path d="M3 8l1.5-4h15L21 8M3 8h18M3 8v11h18V8M9 21v-7h6v7"/></svg>;
    case 'bell': return <svg {...props}><path d="M6 8a6 6 0 1 1 12 0c0 5 2 7 2 7H4s2-2 2-7"/><path d="M10 21a2 2 0 0 0 4 0"/></svg>;
    case 'bell-off': return <svg {...props}><path d="M6 8a6 6 0 0 1 9-5M18 8c0 5 2 7 2 7H7m-3-3l16-12"/></svg>;
    case 'lock': return <svg {...props}><rect x="4" y="11" width="16" height="10" rx="2"/><path d="M8 11V7a4 4 0 1 1 8 0v4"/></svg>;
    case 'crown': return <svg {...props}><path d="M3 7l4 4 5-7 5 7 4-4-2 12H5z"/></svg>;
    case 'tag': return <svg {...props}><path d="M3 12V4h8l10 10-8 8L3 12z"/><circle cx="7.5" cy="7.5" r="1"/></svg>;
    case 'apple': return <svg {...props} fill={stroke} stroke="none"><path d="M16.4 12.5c0-2.6 2.1-3.8 2.2-3.9-1.2-1.8-3.1-2-3.7-2-1.6-.2-3.1.9-3.9.9-.8 0-2-.9-3.4-.9-1.7 0-3.3 1-4.2 2.6-1.8 3.1-.5 7.7 1.3 10.2.9 1.2 1.9 2.6 3.3 2.6 1.3 0 1.8-.8 3.4-.8s2 .8 3.4.8c1.4 0 2.3-1.2 3.2-2.5 1-1.4 1.4-2.7 1.4-2.8-.1 0-2.7-1-2.8-4.2zM13.7 4.6c.7-.9 1.2-2.1 1.1-3.3-1 0-2.3.7-3 1.5-.6.7-1.2 2-1.1 3.1 1.1.1 2.3-.6 3-1.3z"/></svg>;
    case 'google': return <svg width={size} height={size} viewBox="0 0 24 24" style={style}><path fill="#4285F4" d="M21.6 12.2c0-.7-.1-1.4-.2-2.1H12v3.9h5.4a4.6 4.6 0 0 1-2 3v2.5h3.2a9.7 9.7 0 0 0 3-7.3z"/><path fill="#34A853" d="M12 22c2.7 0 5-.9 6.6-2.4l-3.2-2.5a6 6 0 0 1-9-3.1H3.1v2.5A10 10 0 0 0 12 22z"/><path fill="#FBBC05" d="M6.4 13.9a6 6 0 0 1 0-3.8V7.6H3.1a10 10 0 0 0 0 8.8l3.3-2.5z"/><path fill="#EA4335" d="M12 6.6c1.5 0 2.8.5 3.8 1.5l2.8-2.8A10 10 0 0 0 3.1 7.6l3.3 2.5A6 6 0 0 1 12 6.6z"/></svg>;
    case 'drag': return <svg {...props} fill={stroke} stroke="none"><circle cx="9" cy="6" r="1.4"/><circle cx="15" cy="6" r="1.4"/><circle cx="9" cy="12" r="1.4"/><circle cx="15" cy="12" r="1.4"/><circle cx="9" cy="18" r="1.4"/><circle cx="15" cy="18" r="1.4"/></svg>;
    case 'sparkle': return <svg {...props}><path d="M12 3v6m0 6v6M3 12h6m6 0h6"/></svg>;
    case 'wand': return <svg {...props}><path d="M15 4l1.5 3.5L20 9l-3.5 1.5L15 14l-1.5-3.5L10 9l3.5-1.5z"/><path d="M3 21l9-9"/></svg>;
    case 'info': return <svg {...props}><circle cx="12" cy="12" r="9"/><path d="M12 11v5"/><circle cx="12" cy="8" r="0.6" fill={stroke}/></svg>;
    case 'crown': return <svg {...props} fill={stroke} stroke="none"><path d="M3 8l4 4 5-7 5 7 4-4-1 11H4z"/><circle cx="3" cy="8" r="1.2"/><circle cx="21" cy="8" r="1.2"/><circle cx="12" cy="5" r="1.2"/></svg>;
    case 'qr': return <svg {...props}><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/><path d="M14 14h3v3M21 14v7M14 21h3"/></svg>;
    case 'people': return <svg {...props}><circle cx="9" cy="8" r="3.5"/><path d="M3 20a6 6 0 0 1 12 0"/><circle cx="17" cy="8" r="2.5"/><path d="M16 13a5 5 0 0 1 5 5"/></svg>;
    case 'person': return <svg {...props}><circle cx="12" cy="8" r="3.5"/><path d="M5 20a7 7 0 0 1 14 0"/></svg>;
    case 'person-add': return <svg {...props}><circle cx="10" cy="8" r="3.5"/><path d="M3 20a7 7 0 0 1 14 0"/><path d="M19 8v6M16 11h6"/></svg>;
    case 'trash': return <svg {...props}><path d="M4 7h16M9 7V4h6v3M6 7l1 13a2 2 0 0 0 2 2h6a2 2 0 0 0 2-2l1-13"/></svg>;
    case 'edit': return <svg {...props}><path d="M4 20h4l11-11-4-4L4 16v4z"/><path d="M14 6l4 4"/></svg>;
    case 'copy': return <svg {...props}><rect x="8" y="3" width="13" height="13" rx="2"/><path d="M16 21H5a2 2 0 0 1-2-2V8"/></svg>;
    case 'note': return <svg {...props}><path d="M5 4h11l4 4v12a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1V5a1 1 0 0 1 1-1z"/><path d="M14 4v5h5M8 13h8M8 17h6"/></svg>;
    case 'send': return <svg {...props}><path d="M3 11l18-8-8 18-2-8-8-2z"/></svg>;
    case 'sun': return <svg {...props}><circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4 12H2M22 12h-2M5 5l1.4 1.4M17.6 17.6L19 19M5 19l1.4-1.4M17.6 6.4L19 5"/></svg>;
    case 'moon': return <svg {...props}><path d="M21 13a9 9 0 1 1-10-10 7 7 0 0 0 10 10z"/></svg>;
    case 'globe': return <svg {...props}><circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3a14 14 0 0 1 0 18M12 3a14 14 0 0 0 0 18"/></svg>;
    case 'doc': return <svg {...props}><path d="M14 3H7a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V8z"/><path d="M14 3v5h5"/></svg>;
    case 'arrow-r': return <svg {...props}><path d="M5 12h14M13 5l7 7-7 7"/></svg>;
    case 'reorder': return <svg {...props}><path d="M3 6h18M3 12h18M3 18h18"/></svg>;
    case 'palette': return <svg {...props}><path d="M12 3a9 9 0 0 0 0 18c1.5 0 2-1 2-2 0-2 2-2 3-2h2a2 2 0 0 0 2-2 9 9 0 0 0-9-12z"/><circle cx="7.5" cy="11" r="1" fill={stroke}/><circle cx="9.5" cy="7" r="1" fill={stroke}/><circle cx="14.5" cy="7" r="1" fill={stroke}/><circle cx="17" cy="11" r="1" fill={stroke}/></svg>;
    case 'crosshair': return <svg {...props}><circle cx="12" cy="12" r="9"/><path d="M12 3v3M12 18v3M3 12h3M18 12h3M12 12h.01"/></svg>;
    case 'arrow-tr': return <svg {...props}><path d="M7 17L17 7M9 7h8v8"/></svg>;
    case 'agenda': return <svg {...props}><rect x="3" y="4" width="18" height="16" rx="2"/><path d="M7 8h10M7 12h10M7 16h6"/></svg>;
    case 'mail': return <svg {...props}><rect x="3" y="5" width="18" height="14" rx="2"/><path d="M3 7l9 6 9-6"/></svg>;
    default: return null;
  }
};

window.Icon = Icon;
