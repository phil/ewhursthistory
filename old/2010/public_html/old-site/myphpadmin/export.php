<?php
/* $Id: export.php,v 2.18 2005/01/03 13:38:30 nijel Exp $ */
// vim: expandtab sw=4 ts=4 sts=4:

/**
 * Get the variables sent or posted to this script and a core script
 */
require_once('./libraries/grab_globals.lib.php');
require_once('./libraries/common.lib.php');
require_once('./libraries/zip.lib.php');

PMA_checkParameters(array('what'));

// What type of export are we doing?
if ($what == 'excel') {
    $type = 'csv';
} else {
    $type = $what;
}

// Get the functions specific to the export type
require('./libraries/export/' . PMA_securePath($type) . '.php');

// Generate error url
if ($export_type == 'server') {
    $err_url = 'server_export.php?' . PMA_generate_common_url();
} elseif ($export_type == 'database') {
    $err_url = 'db_details_export.php?' . PMA_generate_common_url($db);
} else {
    $err_url = 'tbl_properties_export.php?' . PMA_generate_common_url($db, $table);
}

/**
 * Increase time limit for script execution and initializes some variables
 */
@set_time_limit($cfg['ExecTimeLimit']);

// Start with empty buffer
$dump_buffer = '';
$dump_buffer_len = 0;

// We send fake headers to avoid browser timeout when buffering
$time_start = time();


/**
 * Output handler for all exports, if needed buffering, it stores data into
 * $dump_buffer, otherwise it prints thems out.
 *
 * @param   string  the insert statement
 *
 * @return  bool    Whether output suceeded
 */
function PMA_exportOutputHandler($line)
{
    global $time_start, $dump_buffer, $dump_buffer_len, $save_filename;

    // Kanji encoding convert feature
    if ($GLOBALS['output_kanji_conversion']) {
        $line = PMA_kanji_str_conv($line, $GLOBALS['knjenc'], isset($GLOBALS['xkana']) ? $GLOBALS['xkana'] : '');
    }
    // If we have to buffer data, we will perform everything at once at the end
    if ($GLOBALS['buffer_needed']) {

        $dump_buffer .= $line;
        if ($GLOBALS['onfly_compression']) {

            $dump_buffer_len += strlen($line);

            if ($dump_buffer_len > $GLOBALS['memory_limit']) {
                if ($GLOBALS['output_charset_conversion']) {
                    $dump_buffer = PMA_convert_string($GLOBALS['charset'], $GLOBALS['charset_of_file'], $dump_buffer);
                }
                // as bzipped
                if ($GLOBALS['compression'] == 'bzip'  && @function_exists('bzcompress')) {
                    $dump_buffer = bzcompress($dump_buffer);
                }
                // as a gzipped file
                else if ($GLOBALS['compression'] == 'gzip' && @function_exists('gzencode')) {
                    // without the optional parameter level because it bug
                    $dump_buffer = gzencode($dump_buffer);
                }
                if ($GLOBALS['save_on_server']) {
                    $write_result = @fwrite($GLOBALS['file_handle'], $dump_buffer);
                    if (!$write_result || ($write_result != strlen($dump_buffer))) {
                        $GLOBALS['message'] = sprintf($GLOBALS['strNoSpace'], htmlspecialchars($save_filename));
                        return FALSE;
                    }
                } else {
                    echo $dump_buffer;
                }
                $dump_buffer = '';
                $dump_buffer_len = 0;
            }
        } else {
            $time_now = time();
            if ($time_start >= $time_now + 30) {
                $time_start = $time_now;
                header('X-pmaPing: Pong');
            } // end if
        }
    } else {
        if ($GLOBALS['asfile']) {
            if ($GLOBALS['save_on_server'] && strlen($line) > 0) {
                $write_result = @fwrite($GLOBALS['file_handle'], $line);
                if (!$write_result || ($write_result != strlen($line))) {
                    $GLOBALS['message'] = sprintf($GLOBALS['strNoSpace'], htmlspecialchars($save_filename));
                    return FALSE;
                }
                $time_now = time();
                if ($time_start >= $time_now + 30) {
                    $time_start = $time_now;
                    header('X-pmaPing: Pong');
                } // end if
            } else {
                // We export as file - output normally
                if ($GLOBALS['output_charset_conversion']) {
                    $line = PMA_convert_string($GLOBALS['charset'], $GLOBALS['charset_of_file'], $line);
                }
                echo $line;
            }
        } else {
            // We export as html - replace special chars
            echo htmlspecialchars($line);
        }
    }
    return TRUE;
} // end of the 'PMA_exportOutputHandler()' function

// Will we save dump on server?
$save_on_server = isset($cfg['SaveDir']) && !empty($cfg['SaveDir']) && !empty($onserver);

// Ensure compressed formats are associated with the download feature
if (empty($asfile)) {
    if ($save_on_server) {
        $asfile = TRUE;
    } elseif (isset($compression) && ($compression == 'zip' | $compression == 'gzip' | $compression == 'bzip')) {
        $asfile = TRUE;
    } else {
        $asfile = FALSE;
    }
} else {
    $asfile = TRUE;
}

// Defines the default <CR><LF> format. For SQL always use \n as MySQL wants this on all platforms.
if ($what == 'sql') {
    $crlf = "\n";
} else {
    $crlf = PMA_whichCrlf();
}

$output_kanji_conversion = function_exists('PMA_kanji_str_conv') && $type != 'xls';

// Do we need to convert charset?
$output_charset_conversion = $asfile &&
    $cfg['AllowAnywhereRecoding'] && $allow_recoding
    && isset($charset_of_file) && $charset_of_file != $charset
    && $type != 'xls';

// Set whether we will need buffering
$buffer_needed = isset($compression) && ($compression == 'zip' | $compression == 'gzip' | $compression == 'bzip');

// Use on fly compression?
$onfly_compression = $GLOBALS['cfg']['CompressOnFly'] && isset($compression) && ($compression == 'gzip' | $compression == 'bzip');
if ($onfly_compression) {
    $memory_limit = trim(@ini_get('memory_limit'));
    // 2 MB as default
    if (empty($memory_limit)) $memory_limit = 2 * 1024 * 1024;

    if (strtolower(substr($memory_limit, -1)) == 'm') $memory_limit = (int)substr($memory_limit, 0, -1) * 1024 * 1024;
    elseif (strtolower(substr($memory_limit, -1)) == 'k') $memory_limit = (int)substr($memory_limit, 0, -1) * 1024;
    elseif (strtolower(substr($memory_limit, -1)) == 'g') $memory_limit = (int)substr($memory_limit, 0, -1) * 1024 * 1024 * 1024;
    else $memory_limit = (int)$memory_limit;

    // Some of memory is needed for other thins and as treshold.
    // Nijel: During export I had allocated (see memory_get_usage function)
    //        approx 1.2MB so this comes from that.
    if ($memory_limit > 1500000) $memory_limit -= 1500000;

    // Some memory is needed for compression, assume 1/3
    $memory_limit *= 2/3;
}

// Generate filename and mime type if needed
if ($asfile) {
    $pma_uri_parts = parse_url($cfg['PmaAbsoluteUri']);
    if ($export_type == 'server') {
        if (isset($remember_template)) {
            setcookie('pma_server_filename_template', $filename_template , 0,
                substr($pma_uri_parts['path'], 0, strrpos($pma_uri_parts['path'], '/')),
                '', ($pma_uri_parts['scheme'] == 'https'));
        }
        $filename = str_replace('__SERVER__', $GLOBALS['cfg']['Server']['host'], strftime($filename_template));
    } elseif ($export_type == 'database') {
        if (isset($remember_template)) {
            setcookie('pma_db_filename_template', $filename_template , 0,
                substr($pma_uri_parts['path'], 0, strrpos($pma_uri_parts['path'], '/')),
                '', ($pma_uri_parts['scheme'] == 'https'));
        }
        $filename = str_replace('__DB__', $db, str_replace('__SERVER__', $GLOBALS['cfg']['Server']['host'], strftime($filename_template)));
    } else {
        if (isset($remember_template)) {
            setcookie('pma_table_filename_template', $filename_template , 0,
                substr($pma_uri_parts['path'], 0, strrpos($pma_uri_parts['path'], '/')),
                '', ($pma_uri_parts['scheme'] == 'https'));
        }
        $filename = str_replace('__TABLE__', $table, str_replace('__DB__', $db, str_replace('__SERVER__', $GLOBALS['cfg']['Server']['host'], strftime($filename_template))));
    }

    // convert filename to iso-8859-1, it is safer
    if (!(isset($cfg['AllowAnywhereRecoding']) && $cfg['AllowAnywhereRecoding'] && $allow_recoding)) {
        $filename = PMA_convert_string($charset, 'iso-8859-1', $filename);
    } else {
        $filename = PMA_convert_string($convcharset, 'iso-8859-1', $filename);
    }

    // Generate basic dump extension
    if ($type == 'csv') {
        $filename  .= '.csv';
        $mime_type = 'text/x-comma-separated-values';
    } else if ($type == 'xls') {
        $filename  .= '.xls';
        $mime_type = 'application/vnd.ms-excel';
    } else if ($type == 'xml') {
        $filename  .= '.xml';
        $mime_type = 'text/xml';
    } else if ($type == 'latex') {
        $filename  .= '.tex';
        $mime_type = 'application/x-tex';
    } else {
        $filename  .= '.sql';
        $mime_type = 'text/x-sql';
    }

    // If dump is going to be compressed, set correct encoding or mime_type and add
    // compression to extension
    $content_encoding = '';
    if (isset($compression) && $compression == 'bzip') {
        $filename  .= '.bz2';
        $content_encoding = 'x-bzip2';
    } else if (isset($compression) && $compression == 'gzip') {
        $filename  .= '.gz';
        $content_encoding = 'x-gzip';
    } else if (isset($compression) && $compression == 'zip') {
        $filename  .= '.zip';
        $mime_type = 'application/zip';
    }
}

// Open file on server if needed
if ($save_on_server) {
    if (substr($cfg['SaveDir'], -1) != '/') {
        $cfg['SaveDir'] .= '/';
    }
    $save_filename = $cfg['SaveDir'] . preg_replace('@[/\\\\]@','_',$filename);
    unset($message);
    if (file_exists($save_filename) && empty($onserverover)) {
        $message = sprintf($strFileAlreadyExists, htmlspecialchars($save_filename));
    } else {
        if (is_file($save_filename) && !is_writable($save_filename)) {
            $message = sprintf($strNoPermission, htmlspecialchars($save_filename));
        } else {
            if (!$file_handle = @fopen($save_filename, 'w')) {
                $message = sprintf($strNoPermission, htmlspecialchars($save_filename));
            }
        }
    }
    if (isset($message)) {
        $js_to_run = 'functions.js';
        require_once('./header.inc.php');
        if ($export_type == 'server') {
            $active_page = 'server_export.php';
            require('./server_export.php');
        } elseif ($export_type == 'database') {
            $active_page = 'db_details_export.php';
            require('./db_details_export.php');
        } else {
            $active_page = 'tbl_properties_export.php';
            require('./tbl_properties_export.php');
        }
        exit();
    }
}

/**
 * Send headers depending on whether the user chose to download a dump file
 * or not
 */
if (!$save_on_server) {
    if ($asfile ) {
        // Download
        if (!empty($content_encoding)) {
            header('Content-Encoding: ' . $content_encoding);
        }
        header('Content-Type: ' . $mime_type);
        header('Expires: ' . gmdate('D, d M Y H:i:s') . ' GMT');
        // lem9 & loic1: IE need specific headers
        if (PMA_USR_BROWSER_AGENT == 'IE') {
            header('Content-Disposition: inline; filename="' . $filename . '"');
            header('Cache-Control: must-revalidate, post-check=0, pre-check=0');
            header('Pragma: public');
        } else {
            header('Content-Disposition: attachment; filename="' . $filename . '"');
            header('Pragma: no-cache');
        }
    } else {
        // HTML
        $backup_cfgServer = $cfg['Server'];
        require_once('./header.inc.php');
        $cfg['Server'] = $backup_cfgServer;
        unset($backup_cfgServer);
        echo "\n" . '<div align="' . $cell_align_left . '">' . "\n";
        //echo '    <pre>' . "\n";
        echo '    <form name="nofunction">' . "\n"
           // remove auto-select for now: there is no way to select
           // only a part of the text; anyway, it should obey
           // $cfg['TextareaAutoSelect']
           //. '        <textarea name="sqldump" cols="50" rows="30" onclick="this.select();" id="textSQLDUMP" wrap="OFF">' . "\n";
           . '        <textarea name="sqldump" cols="50" rows="30" id="textSQLDUMP" wrap="OFF">' . "\n";
    } // end download
}

// Check if we have something to export
if ($export_type == 'database') {
    $tables     = PMA_DBI_get_tables($db);
    $num_tables = count($tables);
    if ($num_tables == 0) {
        $message = $strNoTablesFound;
        $js_to_run = 'functions.js';
        require_once('./header.inc.php');
        if ($export_type == 'server') {
            $active_page = 'server_export.php';
            require('./server_export.php');
        } elseif ($export_type == 'database') {
            $active_page = 'db_details_export.php';
            require('./db_details_export.php');
        } else {
            $active_page = 'tbl_properties_export.php';
            require('./tbl_properties_export.php');
        }
        exit();
    }
}

// Fake loop just to allow skip of remain of this code by break, I'd really
// need exceptions here :-)
do {

// Add possibly some comments to export
if (!PMA_exportHeader()) break;

// Will we need relation & co. setup?
$do_relation = isset($GLOBALS[$what . '_relation']);
$do_comments = isset($GLOBALS[$what . '_comments']);
$do_mime     = isset($GLOBALS[$what . '_mime']);
if ($do_relation || $do_comments || $do_mime) {
    require_once('./libraries/relation.lib.php');
    $cfgRelation = PMA_getRelationsParam();
}
if ($do_mime) {
    require_once('./libraries/transformations.lib.php');
}

// Include dates in export?
$do_dates   = isset($GLOBALS[$what . '_dates']);

/**
 * Builds the dump
 */
// Gets the number of tables if a dump of a database has been required
if ($export_type == 'server') {
    /**
     * Gets the databases list - if it has not been built yet
     */
    if ($server > 0 && empty($dblist)) {
        PMA_availableDatabases();
    }

    if (isset($db_select)) {
        $tmp_select = implode($db_select, '|');
        $tmp_select = '|' . $tmp_select . '|';
    }
    // Walk over databases
    foreach ($dblist AS $current_db) {
        if ((isset($tmp_select) && strpos(' ' . $tmp_select, '|' . $current_db . '|'))
            || !isset($tmp_select)) {
            if (!PMA_exportDBHeader($current_db))
                break 2;
            if (!PMA_exportDBCreate($current_db))
                break 2;
            $tables = PMA_DBI_get_tables($current_db);
            foreach ($tables as $table) {
                $local_query  = 'SELECT * FROM ' . PMA_backquote($current_db) . '.' . PMA_backquote($table);
                if (isset($GLOBALS[$what . '_structure'])) {
                    if (!PMA_exportStructure($current_db, $table, $crlf, $err_url, $do_relation, $do_comments, $do_mime, $do_dates))
                        break 3;
                }
                if (isset($GLOBALS[$what . '_data'])) {
                    if (!PMA_exportData($current_db, $table, $crlf, $err_url, $local_query))
                        break 3;
                }
            }
            if (!PMA_exportDBFooter($current_db))
                break 2;
        }
    }
} elseif ($export_type == 'database') {
    if (!PMA_exportDBHeader($db))
        break;

    if (isset($table_select)) {
        $tmp_select = implode($table_select, '|');
        $tmp_select = '|' . $tmp_select . '|';
    }
    $i = 0;
    foreach ($tables as $table) {
        $local_query  = 'SELECT * FROM ' . PMA_backquote($db) . '.' . PMA_backquote($table);
        if ((isset($tmp_select) && strpos(' ' . $tmp_select, '|' . $table . '|'))
            || !isset($tmp_select)) {

            if (isset($GLOBALS[$what . '_structure'])) {
                if (!PMA_exportStructure($db, $table, $crlf, $err_url, $do_relation, $do_comments, $do_mime, $do_dates))
                    break 2;
            }
            if (isset($GLOBALS[$what . '_data'])) {
                if (!PMA_exportData($db, $table, $crlf, $err_url, $local_query))
                    break 2;
            }
        }
    }
    if (!PMA_exportDBFooter($db))
        break;
} else {
    if (!PMA_exportDBHeader($db))
        break;
    // We export just one table

    if ($limit_to > 0 && $limit_from >= 0) {
        $add_query  = ' LIMIT '
                    . (($limit_from > 0) ? $limit_from . ', ' : '')
                    . $limit_to;
    } else {
        $add_query  = '';
    }

    if (!empty($sql_query)) {
        $local_query = $sql_query . $add_query;
        PMA_DBI_select_db($db);
    } else {
        $local_query  = 'SELECT * FROM ' . PMA_backquote($db) . '.' . PMA_backquote($table) . $add_query;
    }

    if (isset($GLOBALS[$what . '_structure'])) {
        if (!PMA_exportStructure($db, $table, $crlf, $err_url, $do_relation, $do_comments, $do_mime, $do_dates))
            break;
    }
    if (isset($GLOBALS[$what . '_data'])) {
        if (!PMA_exportData($db, $table, $crlf, $err_url, $local_query))
            break;
    }
    if (!PMA_exportDBFooter($db))
        break;
}
if (!PMA_exportFooter()) break;

} while (FALSE);
// End of fake loop

if ($save_on_server && isset($message)) {
    $js_to_run = 'functions.js';
    require_once('./header.inc.php');
    if ($export_type == 'server') {
        $active_page = 'server_export.php';
        require('./server_export.php');
    } elseif ($export_type == 'database') {
        $active_page = 'db_details_export.php';
        require('./db_details_export.php');
    } else {
        $active_page = 'tbl_properties_export.php';
        require('./tbl_properties_export.php');
    }
    exit();
}

/**
 * Send the dump as a file...
 */
if (!empty($asfile)) {
    // Convert the charset if required.
    if ($output_charset_conversion) {
        $dump_buffer = PMA_convert_string($GLOBALS['charset'], $GLOBALS['charset_of_file'], $dump_buffer);
    }

    // Do the compression
    // 1. as a gzipped file
    if (isset($compression) && $compression == 'zip') {
        if (@function_exists('gzcompress')) {
            $zipfile = new zipfile();
            $zipfile -> addFile($dump_buffer, substr($filename, 0, -4));
            $dump_buffer = $zipfile -> file();
        }
    }
    // 2. as a bzipped file
    else if (isset($compression) && $compression == 'bzip') {
        if (@function_exists('bzcompress')) {
            $dump_buffer = bzcompress($dump_buffer);
            if ($dump_buffer === -8) {
                require_once('./header.inc.php');
                echo sprintf($strBzError, '<a href="http://bugs.php.net/bug.php?id=17300" target="_blank">17300</a>');
                require_once('./footer.inc.php');
            }
        }
    }
    // 3. as a gzipped file
    else if (isset($compression) && $compression == 'gzip') {
        if (@function_exists('gzencode')) {
            // without the optional parameter level because it bug
            $dump_buffer = gzencode($dump_buffer);
        }
    }

    /* If ve saved on server, we have to close file now */
    if ($save_on_server) {
        $write_result = @fwrite($file_handle, $dump_buffer);
        fclose($file_handle);
        if (strlen($dump_buffer) !=0 && (!$write_result || ($write_result != strlen($dump_buffer)))) {
            $message = sprintf($strNoSpace, htmlspecialchars($save_filename));
        } else {
            $message = sprintf($strDumpSaved, htmlspecialchars($save_filename));
        }

        $js_to_run = 'functions.js';
        require_once('./header.inc.php');
        if ($export_type == 'server') {
            $active_page = 'server_export.php';
            require_once('./server_export.php');
        } elseif ($export_type == 'database') {
            $active_page = 'db_details_export.php';
            require_once('./db_details_export.php');
        } else {
            $active_page = 'tbl_properties_export.php';
            require_once('./tbl_properties_export.php');
        }
        exit();
    } else {
        echo $dump_buffer;
    }
}
/**
 * Displays the dump...
 */
else {
    /**
     * Close the html tags and add the footers in dump is displayed on screen
     */
    //echo '    </pre>' . "\n";
    echo '        </textarea>' . "\n"
       . '    </form>' . "\n";
    echo '</div>' . "\n";
    echo "\n";
?><script language="JavaScript" type="text/javascript">
<!--
    var bodyWidth=null; var bodyHeight=null;
    if (document.getElementById('textSQLDUMP')) {
        bodyWidth  = self.innerWidth;
        bodyHeight = self.innerHeight;
        if(!bodyWidth && !bodyHeight){
            if (document.compatMode && document.compatMode == "BackCompat") {
                bodyWidth  = document.body.clientWidth;
                bodyHeight = document.body.clientHeight;
            } else if (document.compatMode && document.compatMode == "CSS1Compat") {
                bodyWidth  = document.documentElement.clientWidth;
                bodyHeight = document.documentElement.clientHeight;
            }
        }
        document.getElementById('textSQLDUMP').style.width=(bodyWidth-50) + 'px';
        document.getElementById('textSQLDUMP').style.height=(bodyHeight-100) + 'px';
    }
//-->
</script>
<?php
    require_once('./footer.inc.php');
} // end if
?>
