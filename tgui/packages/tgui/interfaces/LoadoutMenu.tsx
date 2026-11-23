import { useState } from 'react';
import { Box, Button, Input, Section, Stack, Tabs } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const categories = [
  'All',
  'Armor',
  'Clothing',
  'Headwear',
  'Cloaks',
  'Accessories',
  'Belts & Bags',
  'Weapons',
  'Tools',
  'Books & Music',
  'Toys',
  'Personal Care',
  'Misc',
  'Point-Cost Items',
  'Point-Cost (No Armor)',
] as const;

type Category = (typeof categories)[number];

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
  const [category, setCategory] = useState<Category>(categories[0]);
  const [search, setSearch] = useState('');
  const query = search.trim().toLowerCase();

  const availableItems = data.loadout_items
    .filter((item) => {
      if (!item.nobility_check || !item.donoritem) {
        return false;
      }
      if (query) {
        return (
          item.name.toLowerCase().includes(query) ||
          (item.triumph_cost || '').toLowerCase().includes(query)
        );
      }
      switch (category) {
        case 'All':
          return true;
        case 'Point-Cost Items':
          return item.point_cost > 0;
        case 'Point-Cost (No Armor)':
          return item.point_cost > 0 && item.category !== 'Armor';
        default:
          return item.category === category;
      }
    })
    .sort((a, b) => a.name.localeCompare(b.name));

  return (
    <Window width={800} height={600}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Tabs className="LoadoutMenu__tabs">
              {categories.map((tab) => (
                <Tabs.Tab
                  key={tab}
                  selected={tab === (query ? 'All' : category)}
                  onClick={() => {
                    setCategory(tab);
                    setSearch('');
                  }}
                >
                  {tab}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Stack.Item>
          <Stack.Item>
            <Stack align="center">
              <Stack.Item grow>
                <Input
                  fluid
                  placeholder="Search all items..."
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
                Searching all items ({availableItems.length})
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
