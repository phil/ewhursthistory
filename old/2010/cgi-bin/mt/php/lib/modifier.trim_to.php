<?php
function smarty_modifier_trim_to($text, $len) {
    $len = intval($len);
    if ($len < strlen($text)) {
        $text = substr($text, 0, $len);
    }
    return $text;
}
?>
