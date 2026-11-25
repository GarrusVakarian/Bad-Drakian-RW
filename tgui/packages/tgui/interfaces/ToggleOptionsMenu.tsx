import { useState } from 'react';
import {
  Button,
  Dropdown,
  Input,
  Section,
  Stack,
  Table,
  Tooltip,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type ToggleEntry = {
  id: string;
  label: string;
  enabled: BooleanLike;
  desc: string;
  disabled?: BooleanLike;
  stat_loss_limit?: number | null;
  gnoll_drain_type?: string;
};

type SelectOption = {
  label: string;
  value: string;
};

type SelectEntry = {
  id: string;
  label: string;
  value: string;
  desc: string;
  options: SelectOption[];
};

type ToggleCategory = {
  name: string;
  entries: ToggleEntry[];
  selects?: SelectEntry[];
};

type Data = {
  categories: ToggleCategory[];
};

export const ToggleOptionsMenu = () => {
  const { act, data } = useBackend<Data>();
  const { categories = [] } = data;

  return (
    <Window width={560} height={840}>
      <Window.Content scrollable>
        <Stack vertical>
          <Stack.Item>
            <Section title="Guidance Notifications">
              <Button
                fluid
                icon="bell"
                onClick={() => act('guidance_notifications')}
              >
                Configure Guidance Notifications
              </Button>
            </Section>
          </Stack.Item>
          {categories.map((category) => (
            <Stack.Item key={category.name}>
              <ToggleCategorySection category={category} />
            </Stack.Item>
          ))}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ToggleCategorySection = ({ category }: { category: ToggleCategory }) => {
  return (
    <Section title={category.name}>
      <Table>
        {category.entries.map((entry) => (
          <ToggleEntryRow key={entry.id} entry={entry} />
        ))}
        {(category.selects || []).map((entry) => (
          <SelectEntryRow key={entry.id} entry={entry} />
        ))}
      </Table>
    </Section>
  );
};

const ToggleEntryRow = ({ entry }: { entry: ToggleEntry }) => {
  const { act } = useBackend<Data>();

  return (
    <>
      <Table.Row className="candystripe">
        <Table.Cell>
          <Tooltip content={entry.desc} position="bottom">
            <Button.Checkbox
              checked={entry.enabled}
              disabled={!!entry.disabled}
              fluid
              onClick={() => act('toggle', { id: entry.id })}
            >
              {entry.label}
            </Button.Checkbox>
          </Tooltip>
        </Table.Cell>
      </Table.Row>
      {!!entry.enabled && entry.stat_loss_limit != null && (
        <DrainOptionsRow
          key={entry.stat_loss_limit}
          value={entry.stat_loss_limit}
          gnollDrain={entry.gnoll_drain_type ?? 'Energy drain'}
        />
      )}
    </>
  );
};

const gnollDrainOptions = ['Energy drain', 'Stat drain'];

const DrainOptionsRow = ({
  value,
  gnollDrain,
}: {
  value: number;
  gnollDrain: string;
}) => {
  const { act } = useBackend<Data>();
  const [text, setText] = useState(String(value));
  const valid = /^(?:[1-9]|1[0-9])$/.test(text);
  const canSave = valid && Number(text) !== value;
  const save = () => {
    if (canSave) {
      act('set_stat_drain_max_loss', { value: Number(text) });
    }
  };

  return (
    <Table.Row className="candystripe">
      <Table.Cell>
        <Stack align="center" ml={2}>
          <Stack.Item>
            <Tooltip content="1–19 points per affected stat." position="bottom">
              <span>Max stat loss:</span>
            </Tooltip>
          </Stack.Item>
          <Stack.Item>
            <Input width={4} value={text} onChange={setText} onEnter={save} />
          </Stack.Item>
          <Stack.Item>
            <Button disabled={!canSave} onClick={save}>
              Save
            </Button>
          </Stack.Item>
          <Stack.Item ml="auto">
            <Tooltip
              content="Applies the next time you become a Gnoll."
              position="bottom"
            >
              <span>Gnoll drain:</span>
            </Tooltip>
          </Stack.Item>
          <Stack.Item>
            <Dropdown
              width="110px"
              options={gnollDrainOptions}
              selected={gnollDrain}
              onSelected={(value) => act('set_gnoll_drain_type', { value })}
            />
          </Stack.Item>
        </Stack>
      </Table.Cell>
    </Table.Row>
  );
};

const SelectEntryRow = ({ entry }: { entry: SelectEntry }) => {
  const { act } = useBackend<Data>();
  const options = Array.isArray(entry.options) ? entry.options : [];

  return (
    <Table.Row className="candystripe">
      <Table.Cell>
        <Tooltip content={entry.desc} position="bottom">
          <Stack align="center">
            <Stack.Item grow>{entry.label}</Stack.Item>
            {options.map((option) => (
              <Stack.Item key={option.value}>
                <Button
                  selected={entry.value === option.value}
                  onClick={() =>
                    act('select', { id: entry.id, value: option.value })
                  }
                >
                  {option.label}
                </Button>
              </Stack.Item>
            ))}
          </Stack>
        </Tooltip>
      </Table.Cell>
    </Table.Row>
  );
};
