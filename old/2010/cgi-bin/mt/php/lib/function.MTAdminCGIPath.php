<?php
function smarty_function_MTAdminCGIPath($args, &$ctx) {
    // status: complete
    // parameters: none
    $path = $ctx->mt->config['AdminCGIPath'];
    $path or $path = $ctx->mt->config['CGIPath'];
    if (substr($path, strlen($path) - 1, 1) != '/')
        $path .= '/';
    return $path;
}
?>
