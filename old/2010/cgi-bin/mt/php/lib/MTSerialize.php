<?php
# Copyright 2001-2005 Six Apart. This code cannot be redistributed without
# permission from www.sixapart.com.  For more information, consult your
# Movable Type license.
#
# $Id$

global $SERIALIZE_VERSION;
$SERIALIZE_VERSION = 2;

class MTSerialize {
    function unserialize($frozen) {
        return $this->_thaw_mt_2($frozen);
    }

    function _thaw_mt_2($frozen) {
        if (substr($frozen, 0, 4) != 'SERG') {
            return NULL;
        }
    
        $thawed = NULL;
        $refs = array(&$thawed);
    
        # The microwave thaws and pops out an element
        $microwave = array(
            'H' => create_function('&$s','   # hashref
                $keys = unpack("Nlen", substr($s["frozen"], $s["pos"], 4));
                $s["pos"] += 4;
                $values = array();
                $s["refs"][] = $values;
                for ($k = 0; $k < $keys["len"]; $k++ ) {
                    $key_name_len = unpack("Nlen", substr($s["frozen"], $s["pos"], 4));
                    $key_name = substr($s["frozen"], $s["pos"] + 4, $key_name_len["len"]);
                    $s["pos"] += 4 + $key_name_len["len"];
                    $h = $s["heater"];
                    $values[$key_name] = $h($s);
                }
                return $values;
            '),
            'A' => create_function('&$s', '   # arrayref
                $array_count = unpack("Nlen", substr($s["frozen"], $s["pos"], 4));
                $s["pos"] += 4;
                $values = array();
                $s["refs"][] = &$values;
                $h = $s["heater"];
                for ($a = 0; $a < $array_count["len"]; $a++) {
                    $values[] = $h($s);
                }
                return $values;
            '),
            'S' => create_function('&$s', '  # scalarref
                $slen = unpack("Nlen", substr($s["frozen"], $s["pos"], 4));
                $col_val = substr($s["frozen"], $s["pos"]+4, $slen["len"]);
                $s["pos"] += 4 + $slen["len"];
                $s["refs"][] = &$col_val;
                return $col_val;
            '),
            'R' => create_function('&$s', '   # refref
                $value = NULL;
                $s["refs"][] = &$value;
                $h = $s["heater"];
                $value = $h($s);
                return $value;
            '),
            '-' => create_function('&$s', '   # scalar value
                $slen = unpack("Nlen", substr($s["frozen"], $s["pos"], 4));
                $col_val = substr($s["frozen"], $s["pos"]+4, $slen["len"]);
                $s["pos"] += 4 + $slen["len"];
                return $col_val;
            '),
            'U' => create_function('&$s', '   # undef
                return NULL;
            '),
            'P' => create_function('&$s', '   # pointer to known ref
                $ptr = unpack("Npos", substr($s["frozen"], $s["pos"], 4));
                $s["pos"] += 4;
                return $s["refs"][$ptr["pos"]];
            ')
        );
    
        $heater = create_function('&$s', '
            $type = substr($s["frozen"], $s["pos"], 1); $s["pos"]++;
            if (array_key_exists($type, $s["microwave"])) {
                $h = $s["microwave"][$type];
                return $h($s);
            } else {
                return NULL;
            }
        ');

        $state = array('pos' => 12, 'heater' => $heater, 'refs' => $refs,
                       'frozen' => $frozen, 'microwave' => $microwave);
        $thawed = $heater($state);
        return $thawed;
    }
}
?>
