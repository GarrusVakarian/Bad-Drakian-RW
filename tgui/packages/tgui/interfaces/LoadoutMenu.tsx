import { useState } from 'react';
import { Box, Button, Input, Section, Stack, Tabs } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const categoryRows = [
  [
    'All',
    'Armor',
    'Clothing',
    'Headwear',
    'Cloaks',
    'Accessories',
    'Belts & Bags',
    'Weapons',
  ],
  ['Tools', 'Books & Music', 'Toys', 'Personal Care', 'Misc', 'Point-Cost Items'],
] as const;

type Category = (typeof categoryRows)[number][number];

type LoadoutItem = {
  name: string;
  desc: string;
  category: Category;
  point_cost: number;
  triumph_cost: string;
  nobility_check: boolean;
  donoritem: boolean;
  ref: string;
  icon: string;
};

type Data = {
  loadout_items: LoadoutItem[];
};

export const LoadoutMenu = () => {
  const { act, data } = useBackend<Data>();
  const [category, setCategory] = useState<Category>(categoryRows[0][0]);
  const [search, setSearch] = useState('');
  const [pointCostOnly, setPointCostOnly] = useState(false);
  const query = search.trim().toLowerCase();
  const activeCategory = query && !pointCostOnly ? 'All' : category;

  const availableItems = data.loadout_items
    .filter((item) => {
      if (!item.nobility_check || !item.donoritem) {
        return false;
      }
      if (
        (pointCostOnly || activeCategory === 'Point-Cost Items') &&
        item.point_cost <= 0
      ) {
        return false;
      }
      if (
        activeCategory !== 'All' &&
        activeCategory !== 'Point-Cost Items' &&
        item.category !== activeCategory
      ) {
        return false;
      }
      return (
        !query ||
        item.name.toLowerCase().includes(query) ||
        (item.triumph_cost || '').toLowerCase().includes(query)
      );
    })
    .sort((a, b) => a.name.localeCompare(b.name));

  return (
    <Window width={800} height={600}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            {categoryRows.map((row) => (
              <Tabs key={row[0]} className="LoadoutMenu__tabs">
                {row.map((tab) => (
                  <Tabs.Tab
                    key={tab}
                    selected={tab === activeCategory}
                    onClick={() => {
                      setCategory(tab);
                      setSearch('');
                    }}
                  >
                    {tab}
                  </Tabs.Tab>
                ))}
                {row === categoryRows[1] && (
                  <Button.Checkbox
                    checked={pointCostOnly}
                    onClick={() => setPointCostOnly(!pointCostOnly)}
                  >
                    Point-Cost only
                  </Button.Checkbox>
                )}
              </Tabs>
            ))}
          </Stack.Item>
          <Stack.Item>
            <Stack align="center">
              <Stack.Item grow>
                <Input
                  fluid
                  placeholder={
                    pointCostOnly
                      ? 'Search paid items in this category...'
                      : 'Search all items...'
                  }
                  value={search}
                  onChange={setSearch}
                />
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon="times"
                  tooltip="Clear search"
                  disabled={!search}
                  onClick={() => setSearch('')}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          {query && (
            <Stack.Item>
              <Box color="label">
                Searching {pointCostOnly ? 'paid items' : 'all items'} (
                {availableItems.length})
              </Box>
            </Stack.Item>
          )}
          <Stack.Item grow style={{ minHeight: 0 }}>
            <Section key={query || category} fill scrollable>
              {availableItems.length === 0 && (
                <Box color="label">
                  {query
                    ? 'No matching items.'
                    : 'No items available in this tab.'}
                </Box>
              )}
              {availableItems.map((item) => (
                <Button
                  key={item.ref}
                  fluid
                  onClick={() => act('choose_item', { ref: item.ref })}
                >
                  <Stack align="center">
                    <Stack.Item>
                      <Box className={item.icon} mr={2} inline />
                    </Stack.Item>
                    <Stack.Item
                      style={{
                        whiteSpace: 'normal',
                        overflowWrap: 'anywhere',
                        minWidth: 0,
                      }}
                    >
                      {item.name} - {item.triumph_cost}
                      {query && (
                        <Box color="label" lineHeight="1.4">
                          {item.category}
                        </Box>
                      )}
                    </Stack.Item>
                  </Stack>
                  {item.desc && (
                    <Box
                      pb={1}
                      style={{
                        whiteSpace: 'pre-wrap',
                        overflowWrap: 'anywhere',
                        lineHeight: 1.4,
                      }}
                    >
                      {item.desc}
                    </Box>
                  )}
                </Button>
              ))}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
