// tokens.jsx — design tokens + theme

const LIGHT = {
  paper: '#F1EDE4',
  surface: '#F7F4EE',
  surface2: '#FCFAF6',
  card: '#FFFFFF',
  ink: '#1B1813',
  ink2: '#57514A',
  ink3: '#837A6A',
  ink4: '#BBB2A4',
  divider: '#E5DFD3',
  divider2: '#EDE8DE',
  accent: '#C2410C',
  accentSoft: '#FBE4D0',
  accentInk: '#7C2A07',
  ok: '#2F6B43',
  okSoft: '#DCEBDF',
  warn: '#B47B1F',
  danger: '#B53D3D',
  dangerSoft: '#F4DEDB',
  checked: '#A39A89',
  shadow: '0 1px 0 rgba(27,24,19,0.05), 0 6px 18px rgba(27,24,19,0.04)',
};

const DARK = {
  paper: '#13110D',
  surface: '#1B1813',
  surface2: '#221E18',
  card: '#26221C',
  ink: '#F2EDE2',
  ink2: '#BFB6A3',
  ink3: '#847C6B',
  ink4: '#5A5246',
  divider: '#2A251F',
  divider2: '#332D26',
  accent: '#E8743A',
  accentSoft: '#3A2316',
  accentInk: '#FCD7BB',
  ok: '#6BB07F',
  okSoft: '#1F3325',
  warn: '#E1B05A',
  danger: '#E47A7A',
  dangerSoft: '#3A2020',
  checked: '#5A5246',
  shadow: '0 1px 0 rgba(0,0,0,0.4), 0 6px 18px rgba(0,0,0,0.3)',
};

const ACCENT_PRESETS = {
  shu:    { light: '#C2410C', dark: '#E8743A', soft_l: '#FBE4D0', soft_d: '#3A2316', name: '朱' },
  matcha: { light: '#1F6B4E', dark: '#6BB07F', soft_l: '#DCEBDF', soft_d: '#1F3325', name: '抹茶' },
  ai:     { light: '#0F4C81', dark: '#5FA0D6', soft_l: '#D8E4F0', soft_d: '#162B3E', name: '藍' },
  sumi:   { light: '#1B1B1B', dark: '#E8E5DD', soft_l: '#E8E5DD', soft_d: '#33302A', name: '墨' },
  kuchiba:{ light: '#B45309', dark: '#E0985A', soft_l: '#F6E1C9', soft_d: '#3A2812', name: '朽葉' },
};

function mkTheme(dark, accentKey = 'shu') {
  const base = dark ? DARK : LIGHT;
  const a = ACCENT_PRESETS[accentKey] || ACCENT_PRESETS.shu;
  return {
    ...base,
    accent: dark ? a.dark : a.light,
    accentSoft: dark ? a.soft_d : a.soft_l,
    dark,
    accentName: a.name,
  };
}

window.LIGHT = LIGHT;
window.DARK = DARK;
window.ACCENT_PRESETS = ACCENT_PRESETS;
window.mkTheme = mkTheme;
