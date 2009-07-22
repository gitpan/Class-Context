package Class::Context;

use strict;
use warnings;

our $VERSION = '0.01';
our $AUTOLOAD;


sub new 
{
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;
    $self->{strict} = $params{strict} || [];
    $self->{registry} = {};
    $self->{operations} = {};
    $self->__defineOperations();

    return $self;
}

sub __defineOperations
{
    my $self = shift;

    $self->{operations}->{get} = sub {
        my ($param) = @_;
        return $self->{registry}->{$param};
    };

    $self->{operations}->{set} = sub {
        my ($param, $value) = @_;
        $self->{registry}->{$param} = $value;
        return 1;
    };
    $self->_defineCustomOperations();

    return 1;
}

# for inheritance
sub _defineCustomOperations{}

sub __execute
{
    my $self = shift;
    my ($method_info, $args) = @_;

    my $operation = shift(@{$method_info});
    my $param_name = lc(shift(@{$method_info}));
    # prevent from execute core methods like DESTROY
    return unless $operation =~ /^[a-z]+?$/;
    unless($self->{operations}->{$operation}){
        $self->_die("operation '$operation' does not exist\n");
    }
    if($self->{strict} && @{$self->{strict}}){
        unless(grep(/^${param_name}$/, @{$self->{strict}})){
            $self->_die("unknown param");
        }
    }
 

    return $self->{operations}->{$operation}->($param_name, @{$args});
}

sub _die
{
    my $self = shift;
    my ($message) = @_;

    die ref($self) . ': ' . $message;
}

sub _parseMethodName
{
    my $self = shift;
    my ($method_name) = @_;

    my @params = split(/(?=[A-Z])/, $method_name);

    return @params;
}

sub AUTOLOAD
{
    my $self = shift;
    my (@args) = @_;

    my $method_name = $AUTOLOAD;
    $method_name =~ s/^.*:://;
    my @method_info = $self->_parseMethodName($method_name);
    
    return $self->__execute(\@method_info, \@args);
}



1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Class::Context - simple implementation of Context Object pattern 

=head1 SYNOPSIS

B<Simple usage>

    use Class::Context;
    my $context = Class::Context->new();

    $context->setExample('exampledata');
    print $context->getExample();
    # exampledata

    $context->setExample2({ some => 'hash'});
    print ref($context->getExample2());
    # HASH

B<strict usage>

    my $context = Class::Context->new( strict => ['example']);

    $context->setExample('exampledata');
    print $context->getExample() . "\n";
    # exampledata

    $context->setExample2('die,hacker!');
    print ref($context->getExample2()) . "\n";
    # died with 'unknown param' message

B<basic method syntax>

(get|set) + ucfirst(lc(paramname))

=head1 DESCRIPTION 

This module does not generate methods on-the-fly and does not use "eval()", "no strict" or other dirty tricks.

=head1 EXTENDING

You can add more functionality by extending Class::Context.

Class::Context provides two basic operations - 'get' and 'set'.
You can add or redefine it. 

    package Mycontext;
    use strict;
    use base 'Class::Context';

    sub _defineCustomOperations
    {
        my $self = shift;

        # $self->{operations} is a hashref, where related functions stored
        # $self->{registry} is a hashref, where params stored

        # add new operation
        $self->{operations}->{load} = sub {
            my ($param) = @_;
            my $object = Some::Factory->create($param);
            $self->{registry}->{$param} = $object;
        };

        # redefine operation get.
        # add ondemand object loading
        $self->{operations}->{get} = sub {
            my ($param) = @_;
            if($self->{registry}->{$param}){
                return $self->{registry}->{$param};
            }else{
                $self->{operations}->{load}->($param);
                return $self->{registry}->{$param};
            }
            return 1;
        };

        # now if you invoke
        # $context->getRequest;
        # new object will be stored in $context->{registry}->{request}
        # or returned if it already exists

        return 1;
    }
    
Also you can redefine default exception method for more useful error handling
    sub _die
    {
        my $self = shift;
        my ($message) = @_;
    
        throw Error::Simple($message);    
    }

    

=head1 SEE ALSO

You can find a helpful information by using Google.

Keywords: 'Context Object Pattern', 'agile software development', 'software design patterns', 'Patterns of Enterprise Application Architecture'.

=head1 AUTHOR

cmapuk[0nline], cmapuk.0nline@gmail.com

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by cmapuk[0nline] 

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
