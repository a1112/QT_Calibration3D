// Exercise the exact QML handler functions without a GUI or user files.
const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const core = fs.readFileSync(path.join(__dirname, '../qml/core/Core.qml'), 'utf8');
const config = fs.readFileSync(path.join(__dirname, '../qml/core/ConfigFile.js'), 'utf8').replace('.pragma library', '');
const funcs = core.match(/    function \w+\([^)]*\)\s*\{[\s\S]*?\n    \}/g).join('\n');
function context() {
  const rows = [{ fileName: '/existing/points.txt', rotate: 1 }];
  let errors = 0;
  const c = vm.createContext({
    qsTr: (s) => s, Qt: { platform: { os: 'osx' } }, console: { log() {} },
    configFileName: '/existing/config.json', statusMessage: '', jsData: { data: rows },
    mainModel: { clear() { rows.length = 0; }, append(row) { rows.push(row); }, get count() { return rows.length; }, get(i) { return rows[i]; } },
    fc: { filename: '', write: () => true },
    fc_o: { readAll: () => '{"data":[]}', lastOperationSucceeded: true, localFilePath: (s) => s },
    fileError: { open() { errors++; } },
    configOpen: { open() {} }, configSave: { open() {} },
  });
  const parser = vm.createContext({}); vm.runInContext(config, parser);
  c.ConfigFile = { parseConfig: parser.parseConfig };
  vm.runInContext(funcs, c);
  return { c, rows, errors: () => errors };
}
test('denied, missing and unknown reads preserve every current row and path', () => {
  for (const code of ['permission_denied', 'not_found', 'io_error']) {
    const { c, rows, errors } = context();
    c.fc_o.lastOperationSucceeded = false; c.fc_o.errorCode = code; c.fc_o.errorString = 'synthetic failure';
    assert.equal(c.openSelectedConfig('/selected/config.json'), false);
    assert.equal(rows.length, 1); assert.equal(rows[0].rotate, 1);
    assert.equal(c.configFileName, '/existing/config.json'); assert.equal(errors(), 1);
    assert.equal(c.statusMessage, '');
    if (code === 'permission_denied') assert.match(c.fileError.informativeText, /Files and Folders/);
    else assert.doesNotMatch(c.fileError.informativeText, /Files and Folders/);
  }
});
test('malformed, empty and partially valid documents never partially replace data', () => {
  for (const text of ['', ' ', '{', 'null', '{}', '{"data":{}}', '{"data":[{"fileName":"ok"},null]}', '{"data":[{"fileName":"a","zoom":"bad"}]}']) {
    const { c, rows, errors } = context(); c.fc_o.readAll = () => text;
    assert.equal(c.openSelectedConfig('/bad.json'), false);
    assert.equal(rows.length, 1); assert.equal(c.configFileName, '/existing/config.json');
    assert.equal(errors(), 1);
  }
});
test('readable empty config data is distinct from empty file and denial', () => {
  const { c, rows, errors } = context();
  assert.equal(c.openSelectedConfig('/empty-data.json'), true);
  assert.equal(rows.length, 0); assert.equal(errors(), 0);
  assert.equal(c.configFileName, '/empty-data.json');
});
test('valid read replaces model only after full validation', () => {
  const { c, rows } = context(); c.fc_o.readAll = () => '{"data":[{"fileName":"/new/ü #.txt","rotate":2}]}';
  assert.equal(c.openSelectedConfig('/new.json'), true);
  assert.equal(rows[0].fileName, '/new/ü #.txt'); assert.equal(rows[0].rotate, 2);
  assert.equal(c.configFileName, '/new.json');
});
test('cancelled open/save causes no I/O, data changes or success message', () => {
  const { c, rows, errors } = context();
  c.fc.write = c.fc_o.readAll = () => { throw Error('must not perform I/O'); };
  assert.equal(c.openSelectedConfig(''), false); assert.equal(c.saveSelectedConfig(''), false);
  assert.equal(rows.length, 1); assert.equal(c.configFileName, '/existing/config.json');
  assert.equal(c.statusMessage, ''); assert.equal(errors(), 0);
});
test('failed atomic save preserves current data/path and supports Save As retry', () => {
  const { c, rows, errors } = context();
  c.fc.write = () => false; c.fc.errorCode = 'permission_denied'; c.fc.errorString = 'denied';
  assert.equal(c.saveSelectedConfig('/denied/config.json'), false);
  assert.equal(rows.length, 1); assert.equal(c.configFileName, '/existing/config.json');
  assert.equal(c.statusMessage, ''); assert.equal(errors(), 1);
  c.fc.write = (text) => { assert.equal(JSON.parse(text).data[0].rotate, 1); return true; };
  assert.equal(c.saveSelectedConfig('/allowed/config.json'), true);
  assert.equal(c.configFileName, '/allowed/config.json'); assert.match(c.statusMessage, /Saved/);
});
test('native file selections replace manual URL slicing on every platform', () => {
  assert.doesNotMatch(core, /substr(?:ing)?\(8/);
  for (const name of ['Main.qml', 'qml/DataListView.qml']) {
    const text = fs.readFileSync(path.join(__dirname, '..', name), 'utf8');
    assert.doesNotMatch(text, /substr(?:ing)?\(8/); assert.match(text, /core\.addPointFile/);
  }
});
