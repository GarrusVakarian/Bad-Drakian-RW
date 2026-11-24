import { Box, Button, Section, Stack } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type GuidanceEntry = {
  id: string;
  label: string;
  desc: string;
  disabled: BooleanLike;
};

type Data = {
  entries: GuidanceEntry[];
  all_disabled: BooleanLike;
};

export const GuidanceNotifications = () => {
  const { act, data } = useBackend<Data>();
  const { entries = [], all_disabled } = data;

  return (
    <Window width={520} height={600}>
      <Window.Content scrollable>
        <Section title="Guidance Notifications">
          <Box mb={2}>
            Check a box to disable that notification. Your choices are saved for
            all your characters.
          </Box>
          <Button.Checkbox
            checked={all_disabled}
            fluid
            mb={2}
            onClick={() => act('toggle', { id: 'all' })}
          >
            Disable all
          </Button.Checkbox>
          <Stack vertical>
            {entries.map((entry) => (
              <Stack.Item key={entry.id}>
                <Button.Checkbox
                  checked={entry.disabled}
                  fluid
                  onClick={() => act('toggle', { id: entry.id })}
                >
                  {entry.label}
                </Button.Checkbox>
                <Box color="label" mt={0.5} mb={1}>
                  {entry.desc}
                </Box>
              </Stack.Item>
            ))}
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
