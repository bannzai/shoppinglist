// tokens.jsx — design tokens + theme

const LIGHT = {
  paper: '#ECECEC',
  surface: '#F4F4F4',
  surface2: '#FAFAFA',
  card: '#FFFFFF',
  ink: '#1A1A1A',
  ink2: '#595959',
  ink3: '#8C8C8C',
  ink4: '#C2C2C2',
  divider: '#E0E0E0',
  divider2: '#EEEEEE',
  accent: '#C2410C',
  accentSoft: '#FBE4D0',
  accentInk: '#7C2A07',
  ok: '#2F6B43',
  okSoft: '#DCEBDF',
  warn: '#B47B1F',
  danger: '#B53D3D',
  dangerSoft: '#F4DEDB',
  checked: '#AEAEAE',
  shadow: '0 1px 0 rgba(0,0,0,0.05), 0 6px 18px rgba(0,0,0,0.04)',
};

const DARK = {
  paper: '#0D0D0D',
  surface: '#1A1A1A',
  surface2: '#242424',
  card: '#2E2E2E',
  ink: '#F5F5F5',
  ink2: '#B3B3B3',
  ink3: '#808080',
  ink4: '#595959',
  divider: '#333333',
  divider2: '#3D3D3D',
  accent: '#E8743A',
  accentSoft: '#3A2316',
  accentInk: '#FCD7BB',
  ok: '#6BB07F',
  okSoft: '#1F3325',
  warn: '#E1B05A',
  danger: '#E47A7A',
  dangerSoft: '#3A2020',
  checked: '#595959',
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
