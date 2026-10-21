import { afterEach, beforeEach, describe, expect, it, mock } from 'bun:test';
import { act, type PropsWithChildren } from 'react';
import { createRoot, type Root } from 'react-dom/client';

let data: Record<string, any>;
const send = mock();
mock.module('../backend', () => ({
  useBackend: () => ({ data, act: send }),
}));
const Frame = ({ children }: PropsWithChildren) => <div>{children}</div>;
mock.module('../layouts', () => ({
  Window: Object.assign(Frame, { Content: Frame }),
}));
const { ContractLedger } = await import('../interfaces/ContractLedger');
const { StewardDefensePanel } = await import(
  '../interfaces/ContractLedgerSteward'
);
const { QuestScroll } = await import('../interfaces/QuestScroll');

Object.assign(globalThis, { IS_REACT_ACT_ENVIRONMENT: true });
let root: Root;
let container: HTMLDivElement;
const render = (element: React.ReactNode) => act(() => root.render(element));
const clickText = (selector: string, text: string) => {
  const element = [...container.querySelectorAll<HTMLElement>(selector)].find(
    (candidate) => candidate.textContent?.trim() === text,
  );
  expect(element).toBeDefined();
  act(() => element!.click());
};

beforeEach(() => {
  send.mockClear();
  container = document.createElement('div');
  document.body.append(container);
  root = createRoot(container);
  data = {
    pool: [],
    active: [],
    regions: [],
    dynamic_roles: [],
    has_account: 1,
    balance: 200,
    active_count: 0,
    active_max: 2,
    user_fellowship_size: 3,
    hoard_recovery_pledge: 200,
    hoard_recovery_fellowship_min: 3,
    hoard_recovery_hoard_min: 200,
    spoils_tax_rate: 0.5,
    hoard_recovery_regions: [
      { region: 'Terrorbog', hoard: 350, danger: 'Bleak', active: 0 },
    ],
  };
});
afterEach(() => {
  act(() => root.unmount());
  container.remove();
});

describe('ported quest interfaces', () => {
  it('renders the hoard call and sends the selected region', () => {
    render(<ContractLedger />);
    expect(container.textContent).toContain('taxed 50%');
    clickText('.Button', 'Call for Recovery');
    expect(send).toHaveBeenCalledWith('request_hoard_recovery', {
      region: 'Terrorbog',
    });
  });

  for (const [label, overrides] of [
    ['no account', { has_account: 0 }],
    ['insufficient fellowship', { user_fellowship_size: 2 }],
    ['insufficient funds', { balance: 199 }],
  ] as const) {
    it(`blocks a hoard request with ${label}`, () => {
      Object.assign(data, overrides);
      render(<ContractLedger />);
      clickText('.Button', 'Call for Recovery');
      expect(send).not.toHaveBeenCalled();
    });
  }

  it('does not offer another writ for an active recovery', () => {
    data.hoard_recovery_regions[0].active = 1;
    render(<ContractLedger />);
    expect(container.textContent).toContain('writ already abroad');
    expect(container.textContent).not.toContain('Call for Recovery');
  });

  it('filters notorious contracts independently from other contracts', () => {
    const contract = {
      reward: 100,
      deposit: 20,
      region: 'Terrorbog',
      required_fellowship_size: 2,
    };
    data.pool = [
      {
        ...contract,
        ref: 'boss',
        title: 'Test outlaw',
        difficulty: 'Notorious',
      },
      {
        ...contract,
        ref: 'ordinary',
        title: 'Test ordinary',
        difficulty: 'Easy',
      },
    ];
    render(<ContractLedger />);
    clickText('.Button', 'Notorious (1)');
    expect(container.textContent).toContain('Test outlaw');
    expect(container.textContent).not.toContain('Test ordinary');
  });

  it('opens scout reports for a player without any official role', () => {
    data.scout_regions = [
      {
        region_name: 'Terrorbog',
        danger_level: 'Bleak',
        danger_color: '#800080',
        ic_descriptions: ['a hoard of around 350 mammons'],
        blockaded: 0,
      },
    ];
    render(<ContractLedger />);
    clickText('.ContractLedger__HeaderMode', 'Scout Reports');
    expect(container.textContent).toContain('a hoard of around 350 mammons');
    expect(container.querySelector('.ContractLedger__FilterBar')).toBeNull();
    clickText('.ContractLedger__HeaderMode', 'Grand Contract Ledger');
    expect(
      container.querySelector('.ContractLedger__FilterBar'),
    ).not.toBeNull();
  });

  it('commissions hoard recovery as a bearer writ', () => {
    Object.assign(data, {
      defense_costs: { 'Hoard Recovery': 200 },
      defense_regions_by_type: { 'Hoard Recovery': ['Terrorbog'] },
      pledge_available: 1,
      pledge_balance: 500,
    });
    render(<StewardDefensePanel />);
    const region = container.querySelectorAll('select')[1];
    act(() => {
      region.value = 'Terrorbog';
      region.dispatchEvent(new Event('change', { bubbles: true }));
    });
    const dispatch = [...container.querySelectorAll('button')].find((button) =>
      button.textContent?.includes('Print Writ'),
    )!;
    expect(dispatch).toBeDefined();
    act(() => dispatch.click());
    expect(send).toHaveBeenCalledWith('commission_defense', {
      type: 'Hoard Recovery',
      region: 'Terrorbog',
      destination: null,
      in_hands: 1,
      levy_exempt: 0,
      bonus_pay_level: 0,
      funding: 'pledge',
    });
  });

  it('displays the live notorious reward and hunt countdown', () => {
    data = {
      title: 'Test outlaw',
      issued_to: 'Test hunter',
      reward: 225,
      levy_rate: 0.1,
      guild_cut_rate: 0.1,
      hunt_timer_label: 'Hunt ends in',
      hunt_timer_seconds: 65,
    };
    render(<QuestScroll />);
    expect(container.textContent).toContain('225 mammon');
    expect(container.textContent).toContain('180 in hand after deductions');
    expect(container.textContent).toContain('Hunt ends in');
    expect(container.textContent).toContain('1:05');
  });
});
