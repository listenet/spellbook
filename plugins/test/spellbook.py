#!/usr/bin/env


class TestModule(object):
    """The custom tests of spellbook.*"""

    def tests(self):
        return {
            'empty': self.is_empty,
        }

    def is_empty(self, sequence):
        return len(sequence) == 0
