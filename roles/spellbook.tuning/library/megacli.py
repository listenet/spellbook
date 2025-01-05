#!/usr/bin/python
# -*- coding: utf-8 -*-
#
# Copyright: (c) 2019, Jiangge Zhang <tonyseek@gmail.com>
# GNU General Public License v3.0+
# (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function

import re

from ansible.module_utils.basic import AnsibleModule


__metaclass__ = type


MEGACLI_GETPROP_RE = re.compile(r'Cache Policy:([a-zA-Z0-9, ]+)')
MEGACLI_EXITCODE_RE = re.compile(r'Exit Code: ([0-9x]+)')

RAID_WB = 'WriteBack'
RAID_CACHE_BAD_BBU = 'Write Cache OK if bad BBU'
RAID_NO_CACHE_BAD_BBU = 'No Write Cache if bad BBU'


def extract_megacli_getprop(stdout):
    """
    Example:

    >>> stdout = 'Adapter 0-VD 0(target id: 0): Cache Policy:WriteBack, '
    >>> stdout += 'ReadAhead, Direct, Write Cache OK if bad BBU\\n\\n'
    >>> stdout += 'Exit Code: 0x00\\n'
    >>> extract_megacli_getprop(stdout)
    (['WriteBack', 'ReadAhead', 'Direct', 'Write Cache OK if bad BBU'], 0)
    """
    prop = MEGACLI_GETPROP_RE.search(stdout, re.MULTILINE)
    code = MEGACLI_EXITCODE_RE.search(stdout, re.MULTILINE)
    if not prop or not code:
        return [], None
    prop = [p.strip() for p in prop.group(1).split(',') if p.strip()]
    code = int(code.group(1), 16)
    return prop, code


def check_present(module, megacli_path):
    cmd = [megacli_path, '-LDGetProp', '-Cache', '-LALL', '-aALL']
    rc, stdout, _ = module.run_command(cmd, check_rc=True)
    if rc != 0:
        return
    return extract_megacli_getprop(stdout)


def set_force_writeback(module, megacli_path):
    prop, code = check_present(module, megacli_path)
    policy = ', '.join(prop)
    if code != 0:
        module.fail_json(msg='RAID card not found: code=%s' % code)
        return
    if RAID_WB not in prop:
        module.fail_json(msg='WriteBack is not supported: policy=%s' % policy)
        return
    if RAID_CACHE_BAD_BBU in prop:
        return False  # unchanged
    if RAID_NO_CACHE_BAD_BBU not in prop:
        module.fail_json(msg='BBU policy is unknown: policy=%s' % policy)
        return

    if module.check_mode:
        return True

    cmd = [megacli_path]
    cmd.extend(['-LDSetProp', '-ForcedWB', '-Immediate', '-Lall', '-aAll'])
    rc, stdout, _ = module.run_command(cmd, check_rc=True)
    if rc != 0:
        return
    code = MEGACLI_EXITCODE_RE.search(stdout, re.MULTILINE)
    if not code or int(code.group(1), 16) != 0:
        module.fail_json(msg='ForcedWB fail: %s' % stdout)
        return
    return True


def main():
    module = AnsibleModule(
        supports_check_mode=True,
        argument_spec=dict(
            path=dict(type='str'),
            force_writeback=dict(type='bool', default=False),
        ),
    )

    path = module.params['path']
    changed = False

    if module.params['force_writeback']:
        changed = set_force_writeback(module, path)
    else:
        module.fail_json(msg='force_writeback=no is not supported yet.')

    policy, code = check_present(module, path)
    args = dict(
        changed=changed,
        failed=False,
        policy=policy,
        code=code,
        force_writeback=module.params['force_writeback'],
    )
    module.exit_json(**args)


if __name__ == '__main__':
    main()
