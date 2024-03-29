# Copyright 2001-2005 Six Apart. This code cannot be redistributed without
# permission from www.sixapart.com.  For more information, consult your
# Movable Type license.
#
# $Id: postgres.pm 16523 2005-08-22 21:20:12Z bchoate $

package MT::ObjectDriver::DBI::postgres;
use strict;

use MT::ObjectDriver::DBI;
@MT::ObjectDriver::DBI::postgres::ISA = qw( MT::ObjectDriver::DBI );

sub ts2db {
    my $ts = sprintf '%04d-%02d-%02d %02d:%02d:%02d', unpack 'A4A2A2A2A2A2', $_[1];
    $ts = undef if $ts eq '0000-00-00 00:00:00';
    $ts;
}

sub db2ts {
    my $ts = $_[1];
    $ts =~ s/(?:\+|-)\d{2}$//;
    $ts =~ tr/\- ://d;
    $ts;
}

sub init {
    my $driver = shift;
    $driver->SUPER::init(@_);
    my $cfg = $driver->cfg;
    my $dsn = 'dbi:Pg:dbname=' . $cfg->Database;
    $dsn .= ';host=' . $cfg->DBHost if $cfg->DBHost;
    $dsn .= ';port=' . $cfg->DBPort if $cfg->DBPort;
    $driver->{dbh} = DBI->connect($dsn, $cfg->DBUser, $cfg->DBPassword,
        { RaiseError => 0, PrintError => 0 })
        or return $driver->error("Connection error: " . $DBI::errstr);
    $driver;
}

sub _prepare_from_where {
    my $driver = shift;
    my($class, $terms, $args) = @_;
    my($sql, @bind);

    ## Prefix the table name with 'mt_' to make it distinct.
    my $tbl = $class->datasource;
    my $tbl_name = 'mt_' . $tbl;

    my($w_sql, $w_terms, $w_bind) = ('', [], []);
    if (my $join = $args->{join}) {
        my($j_class, $j_col, $j_terms, $j_args) = @$join;
        my $j_tbl = $j_class->datasource;
        my $j_tbl_name = 'mt_' . $j_tbl;

        $sql = "from $tbl_name, $j_tbl_name\n";
        ($w_sql, $w_terms, $w_bind) =
            $driver->build_sql($j_class, $j_terms, $j_args, $j_tbl);
        push @$w_terms, "${tbl}_id = ${j_tbl}_$j_col";

        ## We are doing a join, but some args and terms may have been
        ## specified for the "outer" piece of the join--for example, if
        ## we are doing a join of entry and comments where we end up with
        ## entries, sorted by the created_on date in the entry table, or
        ## filtered by author ID. In that case the sort or author ID will
        ## be specified in the spec for the Entry load, not for the join
        ## load.
        my($o_sql, $o_terms, $o_bind) =
            $driver->build_sql($class, $terms, $args, $tbl);
        $w_sql .= $o_sql;
        if ($o_terms && @$o_terms) {
            push @$w_terms, @$o_terms;
            push @$w_bind, @$o_bind;
        }

        if ($j_args->{unique} && $j_args->{'sort'}) {
            ## If it's a distinct with sorting, we need to create
            ## a subselect to select the proper set of rows.
            my $cols = $class->column_names;
            my $s_sql = "from (select " .
                        join(', ', map "${tbl}_$_", @$cols) .
                        ", ${j_tbl}_$j_args->{'sort'}\n";
            $sql = $s_sql . $sql;
            $w_sql .= ") t\n";
        }

        if (my $n = $j_args->{limit}) {
            $n =~ s/\D//g;   ## Get rid of any non-numerics.
            $w_sql .= sprintf "limit %d%s\n", $n,
                ($args->{offset} ? " offset $args->{offset}" : "");
        }
    } else {
        $sql = "from $tbl_name\n";
        ($w_sql, $w_terms, $w_bind) = $driver->build_sql($class, $terms, $args, $tbl);
    }
    $sql .= "where " . join(' and ', @$w_terms) . "\n" if @$w_terms;
    $sql .= $w_sql;
    @bind = @$w_bind;
    if (my $n = $args->{limit}) {
        $sql .= sprintf "limit %d%s\n", $n,
            ($args->{offset} ? " offset $args->{offset}" : "");
    }
    ($class->datasource, $sql, \@bind);
}

# return the third argument for bind_param, generally to 
# tell it what type of data is being bound.
#
# We may also need this when specifying limit attributes as
# bound parameters

sub bind_param_attributes {
    my ($driver, $data_type) = @_;
    if ($data_type eq 'blob') {
        return {pg_type => DBD::Pg::PG_BYTEA()};
    }
    return undef;
}

sub generate_id {
    my $driver = shift;
    my($class) = @_;
    my $seq = 'mt_' . $class->datasource . '_' .
              $class->properties->{primary_key};
    my $dbh = $driver->{dbh};
    my $sth = $dbh->prepare("select nextval('$seq')")
        or return $driver->error($dbh->errstr);
    $sth->execute
        or return $driver->error($dbh->errstr);
    $sth->bind_columns(undef, \my($id));
    $sth->fetch;
    $sth->finish;
    $id;
}

sub column_defs {
    my $driver = shift;
    my ($type) = @_;

    my $ds = $type->properties->{datasource};
    my $dbh = $driver->{dbh};
    return undef unless $dbh;

    my $attr = $dbh->func('mt_' . $ds, 'table_attributes') or return undef;
    return undef unless @$attr;

    my $defs = {};
    foreach my $col (@$attr) {
        my $coltype = $driver->db2type($col->{TYPE});
        my $colname = lc $col->{NAME};
        $colname =~ s/^\Q$ds\E_//i;
        $defs->{$colname}{type} = $coltype;
        if ( $coltype eq 'string') {
            if (defined $col->{SIZE}) {
                $defs->{$colname}{size} = $col->{SIZE};
            } else {
                $defs->{$colname}{type} = 'text';
            }
        }
        if ( $col->{NOTNULL} ) {
            $defs->{$colname}{not_null} = 1;
        }
        if ( $col->{PRIMARY_KEY} ) {
            $defs->{$colname}{key} = 1;
        }
    }
    $defs;
}

sub type2db {
    my $driver = shift;
    my ($def) = @_;
    my $type = $def->{type};
    if ($type eq 'string') {
        return 'varchar(' . $def->{size} . ')';
    } elsif ($type eq 'smallint' ) {
        return 'smallint';
    } elsif ($type eq 'boolean') { 
        return 'smallint';
    } elsif ($type eq 'datetime') {
        return 'timestamp';
    } elsif ($type eq 'timestamp') {
        return 'timestamp';
    } elsif ($type eq 'integer') {
        return 'integer';
    } elsif ($type eq 'blob') {
        return 'bytea';
    } elsif ($type eq 'text') {
        return 'text';
    } elsif ($type eq 'float') {
        return 'float';
    }
}

sub can_add_column { 1 }
sub can_drop_column { 1 }
sub can_alter_column { 0 }

sub alter_column_sql {
    my $driver = shift;
    my $sql = $driver->SUPER::alter_column_sql(@_);
    $sql =~ s/\bmodify\b/alter column/;
    $sql;
}

sub _cast_column {
    my $driver = shift;
    my ($class, $name, $from_def) = @_;
    my $ds = $class->properties->{datasource};
    my $def = $class->column_def($name);
    if (($from_def->{type} eq 'text') && ($def->{type} eq 'blob')) {
        "cast(decode(${ds}_$name, 'escape') as " . $driver->type2db($def) . ')';
    } elsif (($from_def->{type} eq 'blob') && ($def->{type} eq 'text')) {
        "cast(encode(${ds}_$name, 'escape') as " . $driver->type2db($def) . ')';
    } else {
        "cast(${ds}_$name as " . $driver->type2db($def) . ')';
    }
}

sub drop_sequence {
    my $driver = shift;
    my ($class) = @_;

    # do this, but ignore error since it usually means the
    # sequence didn't exist to begin with
    my $ds = $class->properties->{datasource};
    my $def = $class->column_def('id');
    if ($def->{type} eq 'integer') {
        $driver->{dbh}->do('drop sequence mt_' . $ds . '_id');
    }
    1;
}

sub create_sequence {
    my $driver = shift;
    my ($class) = @_;

    my $def = $class->column_def('id');
    if ($def->{type} eq 'integer') {
        my $ds = $class->properties->{datasource};
        my $max_sql = 'select max(' . $ds . '_id) from mt_' . $ds;
        my ($start) = $driver->{dbh}->selectrow_array($max_sql);
        $driver->{dbh}->do('create sequence mt_' . $ds . '_id' .
            ($start ? (' start ' . ($start+1)) : ''));
    }
    1;
}

1;
