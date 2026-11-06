import { useState } from 'react';
import {
  Box,
  Button,
  Input,
  NoticeBox,
  Section,
  Stack,
  Table,
  TextArea,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  balance: number;
  paper_cost: number;
  quill_cost: number;
  letter_cost: number;
  letter_limit: number;
  name_limit: number;
  free_send_remaining_ds: number;
  marquette_in_use: boolean;
};

const formatting = [
  ['# text', 'Header'],
  ['|text|', 'Centered text'],
  ['**text**', 'Bold'],
  ['*text*', 'Italic'],
  ['^text^', 'Larger text'],
  ['((text))', 'Smaller text'],
  ['%s', 'Sign with your character name'],
  ['%f', 'Add a field for the reader to fill in'],
  ['* item', 'List item'],
  ['  * item', 'Nested list item'],
  ['---', 'Horizontal rule'],
  ['-=FFFFFFtext=-', 'Colored text (hex color)'],
];

export const Hermes = () => {
  const { act, data } = useBackend<Data>();
  const {
    balance,
    paper_cost,
    quill_cost,
    letter_cost,
    letter_limit,
    name_limit,
    free_send_remaining_ds,
    marquette_in_use,
  } = data;
  const [recipient, setRecipient] = useState('');
  const [sender, setSender] = useState('');
  const [content, setContent] = useState('');
  const [showHelp, setShowHelp] = useState(false);
  const seconds = Math.ceil(free_send_remaining_ds / 10);
  const isFree = seconds === 0;
  const cooldown = `${Math.floor(seconds / 60)}m ${seconds % 60}s`;

  return (
    <Window title="HERMES" width={440} height={480}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Stack align="center">
              <Stack.Item grow>
                <Box bold color={balance ? 'good' : 'label'}>
                  {balance} Mammon
                </Box>
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon="scroll"
                  disabled={marquette_in_use || balance < paper_cost}
                  onClick={() => act('buy_paper')}
                >
                  Paper ({paper_cost})
                </Button>
                <Button
                  icon="feather"
                  disabled={marquette_in_use || balance < quill_cost}
                  onClick={() => act('buy_quill')}
                >
                  Quill ({quill_cost})
                </Button>
                <Button
                  icon="coins"
                  color="caution"
                  disabled={marquette_in_use || !balance}
                  onClick={() => act('refund')}
                >
                  Refund
                </Button>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          {!!marquette_in_use && (
            <Stack.Item>
              <NoticeBox>The MARQUETTE is in use.</NoticeBox>
            </Stack.Item>
          )}
          <Stack.Item grow>
            <Section
              fill
              scrollable
              title={
                isFree
                  ? 'Write Letter (free letter ready)'
                  : `Write Letter (${letter_cost} mammon, free in ${cooldown})`
              }
              buttons={
                <Button
                  icon="question-circle"
                  selected={showHelp}
                  onClick={() => setShowHelp(!showHelp)}
                >
                  Formatting
                </Button>
              }
            >
              {showHelp ? (
                <>
                  <Table>
                    {formatting.map(([example, meaning]) => (
                      <Table.Row key={example}>
                        <Table.Cell pr={1} style={{ whiteSpace: 'pre' }}>
                          {example}
                        </Table.Cell>
                        <Table.Cell>{meaning}</Table.Cell>
                      </Table.Row>
                    ))}
                  </Table>
                  <Box mt={1} color="label">
                    The From name is appended as a signature. Leave it blank to
                    send anonymously.
                  </Box>
                </>
              ) : (
                <Stack vertical fill>
                  <Stack.Item>
                    <Stack>
                      <Stack.Item grow>
                        <Input
                          fluid
                          placeholder="To: Name or #number"
                          value={recipient}
                          onChange={(value) =>
                            setRecipient(value.slice(0, name_limit))
                          }
                        />
                      </Stack.Item>
                      <Stack.Item grow>
                        <Input
                          fluid
                          placeholder="From: Anonymous"
                          value={sender}
                          onChange={(value) =>
                            setSender(value.slice(0, name_limit))
                          }
                        />
                      </Stack.Item>
                    </Stack>
                  </Stack.Item>
                  <Stack.Item grow>
                    <TextArea
                      fluid
                      height="100%"
                      placeholder="Write your letter here..."
                      value={content}
                      maxLength={letter_limit}
                      onChange={setContent}
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      fluid
                      icon="paper-plane"
                      color={isFree ? 'good' : undefined}
                      disabled={
                        marquette_in_use ||
                        !recipient.trim() ||
                        !content.trim() ||
                        (!isFree && balance < letter_cost)
                      }
                      onClick={() =>
                        act('send_letter', { recipient, sender, content })
                      }
                    >
                      {isFree ? 'Send Letter (Free)' : 'Send Letter'}
                    </Button>
                  </Stack.Item>
                </Stack>
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
