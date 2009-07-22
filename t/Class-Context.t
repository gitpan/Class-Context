# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Class-Context.t'

#########################

use Test ;
BEGIN { plan tests => 6 };
use Class::Context;

ok(1);

my $context  = Class::Context->new;
ok($context->setTestparam('xxx'));
ok($context->getTestparam() eq 'xxx');

ok($context = Class::Context->new(strict => ['goodparam']));
ok($context->setGoodparam('xxx'));
eval {$context->setBadparam('xxx')};
ok($@ =~ /^Class::Context: unknown param/);


