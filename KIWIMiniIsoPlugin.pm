################################################################
# Copyright (c) 2014, 2015 SUSE LLC
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program (see the file LICENSE); if not, write to the
# Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
#
################################################################
package KIWIMiniIsoPlugin;

use strict;
use warnings;

use base "KIWIBasePlugin";
use Data::Dumper;
use Config::IniFiles;
use File::Find;
use FileHandle;
use Carp;
use File::Basename qw /dirname/;

sub new {
    # ...
    # Create a new KIWIMiniIsoPlugin object
    # ---
    my $class   = shift;
    my $handler = shift;
    my $config  = shift;
    my $configpath;
    my $configfile;
    my $this = KIWIBasePlugin -> new($handler);
    bless ($this, $class);
    if ($config =~ m{(.*)/([^/]+)$}x) {
        $configpath = $1;
        $configfile = $2;
    }
    if ((! $configpath) || (! $configfile)) {
        $this->logMsg("E",
            "wrong parameters in plugin initialisation\n"
        );
        return;
    }
    ## plugin content:
    #-----------------
    #[base]
    # name = KIWIEulaPlugin
    # order = 3
    # defaultenable = 1
    #
    #[target]
    # targetfile = content
    # targetdir = $PRODUCT_DIR
    # media = (list of numbers XOR "all")
    #
    my $ini = Config::IniFiles -> new (
        -file => "$configpath/$configfile"
    );
    my $name   = $ini->val('base', 'name');
    my $order  = $ini->val('base', 'order');
    my $enable = $ini->val('base', 'defaultenable');
    # if any of those isn't set, complain!
    if (not defined($name)
        or not defined($order)
        or not defined($enable)
    ) {
        $this->logMsg("E",
            "Plugin ini file <$config> seems broken!\n"
        );
        return;
    }
    $this->name($name);
    $this->order($order);
    if($enable != 0) {
        $this->ready(1);
    }
    return $this;
}

sub execute {
    my $this = shift;
    if(not ref($this)) {
        return;
    }
    my $retval = 0;
    if($this->{m_ready} == 0) {
        return $retval;
    }
    my $ismini = $this->collect()->productData()->getVar("FLAVOR");
    if(not defined($ismini)) {
        $this->logMsg("W", "FLAVOR not set?");
        return $retval;
    }
    if ($ismini !~ m{Test}i) {
        $this->logMsg("I",
            "Nothing to do for media type <$ismini>"
        );
        return $retval;
    }
    
    my $dir = $this->collect()->basesubdirs()->{1};
        $this->logMsg("I",
            "BASE CD <$dir>"
        );
    
    system("find $dir");
    return $retval;
}


1;
