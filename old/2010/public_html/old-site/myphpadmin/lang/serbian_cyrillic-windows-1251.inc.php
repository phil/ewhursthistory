<?php
/* $Id: serbian_cyrillic-windows-1251.inc.php,v 2.60 2004/12/28 16:34:49 nijel Exp $ */

/**
 * Translated by:
 *     Igor Mladenovic <mligor@zimco.com>, David Trajkovic <tdavid@ptt.yu>
 *     Mihailo Stefanovic <mikis@users.sourceforge.net>, Branislav Jovanovic <fangorn@eunet.yu>
 */

$charset = 'windows-1251';
$text_dir = 'ltr'; // ('ltr' for left to right, 'rtl' for right to left)
$left_font_family = 'verdana, arial, helvetica, geneva, sans-serif';
$right_font_family = 'arial, helvetica, geneva, sans-serif';
$number_thousands_separator = ',';
$number_decimal_separator = '.';
// shortcuts for Byte, Kilo, Mega, Giga, Tera, Peta, Exa
$byteUnits = array('������', '��', '��', '��', '��', '��', '��');

$day_of_week = array('���', '���', '���', '���', '���', '���', '���');
$month = array('���', '���', '���', '���', '��', '���', '���', '���', '���', '���', '���', '���');
// See http://www.php.net/manual/en/function.strftime.php to define the
// variable below
$datefmt = '%d. %B %Y. � %H:%M';
$timespanfmt = '%s ����, %s ����, %s ������ � %s �������';

$strAPrimaryKey = '�������� ��� �� ������ ����� %s';
$strAbortedClients = '���������';
$strAbsolutePathToDocSqlDir = '������� ��������� ������ �� ������������ docSQL �� ��� �������';
$strAccessDenied = '������� ������';
$strAccessDeniedExplanation = 'phpMyAdmin �� ������� �� �� ������ �� MySQL ������, ��� �� ������ ����� ����������. ��������� ����� ��������, ���������� ��� � ������� � config.inc.php � ������� �� �� ��������� �������� ��� ��� ������ �� �������������� MySQL �������.';
$strAction = '�����';
$strAddAutoIncrement = '���� AUTO_INCREMENT ��������';
$strAddConstraints = '���� ���������';
$strAddDeleteColumn = '����/������ ������';
$strAddDeleteRow = '����/������ ��� �� ���������';
$strAddDropDatabase = '���� DROP DATABASE';
$strAddFields = '���� %s ���';
$strAddHeaderComment = '���� �������� � ������� (\\n ������� �����)';
$strAddIfNotExists = '���� \'IF NOT EXISTS\'';
$strAddIntoComments = '���� � ���������';
$strAddNewField = '���� ���� ���';
$strAddPrivilegesOnDb = '���� ���������� �� ������ ����';
$strAddPrivilegesOnTbl = '���� ���������� �� ������ ������';
$strAddSearchConditions = '���� ������ ������������ (��� "WHERE" �����):';
$strAddToIndex = '���� � ��� &nbsp;%s&nbsp;������(�)';
$strAddUser = '���� ����� ���������';
$strAddUserMessage = '������ ��� ����� ���������.';
$strAddedColumnComment = '����� �� �������� ������';
$strAddedColumnRelation = '������ �� ������� ������';
$strAdministration = '�������������';
$strAffectedRows = '���������� ������:';
$strAfter = '����� %s';
$strAfterInsertBack = '����� �� ��������� ������';
$strAfterInsertNewInsert = '���� ��� ����� ���� ���';
$strAfterInsertSame = '����� �� �� ��� ������';
$strAll = '���';
$strAllTableSameWidth = '������ ���� ������ ���� ������?';
$strAlterOrderBy = '������� �������� � ������';
$strAnIndex = 'ʚ�� �� ������ ����� %s';
$strAnalyzeTable = '��������� ������';
$strAnd = '�';
$strAny = '���� ���';
$strAnyHost = '���� ��� �������';
$strAnyUser = '���� ��� ��������';
$strApproximateCount = '���� ���� ���������. ������ FAQ 3.11';
$strArabic = '�������';
$strArmenian = '���������';
$strAscending = '������';
$strAtBeginningOfTable = '�� ������� ������';
$strAtEndOfTable = '�� ���� ������';
$strAttr = '��������';
$strAutodetect = '����������';
$strAutomaticLayout = '���������� ��������';

$strBack = '�����';
$strBaltic = '��������';
$strBeginCut = '������� ���';
$strBeginRaw = '������� ������';
$strBinLogEventType = '����� �������';
$strBinLogInfo = '����������';
$strBinLogName = '����� ��������';
$strBinLogOriginalPosition = '���������� �������';
$strBinLogPosition = '�������';
$strBinLogServerId = '�� �������';
$strBinary = '�������';
$strBinaryDoNotEdit = '������� - �� ���';
$strBinaryLog = '������� �������';
$strBookmarkAllUsers = '������� ������ ��������� �� �������� ���� �������� �����';
$strBookmarkDeleted = '���������� �� ������ �������.';
$strBookmarkLabel = '�����';
$strBookmarkOptions = '����� �����������';
$strBookmarkQuery = '������� SQL-����';
$strBookmarkThis = '������� SQL-����';
$strBookmarkView = '���� ����';
$strBrowse = '�������';
$strBrowseForeignValues = '�������� ������ ���������';
$strBulgarian = '��������';
$strBzError = 'phpMyAdmin ��� ����� �� ��������� ������ ���� ���� ���������� BZ2 ��������� � ��� ������ PHP-�. ���������� �� �� �������� <code>$cfg[\'BZipDump\']</code> ��������� � ���oj phpMyAdmin ��������������j �������� �� <code>FALSE</code>. ��� ������ �� ��������� ��������� BZ2 ���������, ������� �� �� ������ �� ����� ������ PHP-�. ������ PHP ������� � �������� %s �� ������.';
$strBzip = '"����-�����"';

$strCSVOptions = 'CSV �����';
$strCalendar = '��������';
$strCannotLogin = '�� ���� �� �� ������� �� MySQL ������';
$strCantLoad = '�� ���� �� ������ ��������� %s,<br />����� ��������� PHP ������������';
$strCantLoadRecodeIconv = '�� ���� �� ������ iconv ��� recode ��������� �������� �� ��������� ������� �������, �������� PHP �� ������� �������� ���� ��������� ��� ���������� ��������� ������� ������� � phpMyAdmin-�.';
$strCantRenameIdxToPrimary = '�� ���� �� �������� ��� � PRIMARY (��������) !';
$strCantUseRecodeIconv = '�� ���� �� �������� iconv ��� libiconv ��� recode_string ������� ���� ��������� ������� �� �� �������. ��������� ���� PHP ������������.';
$strCardinality = '������������';
$strCarriage = '���� ��� (carriage return): \\r';
$strCaseInsensitive = '�� �������� ���� � ������ �����';
$strCaseSensitive = '�������� ���� � ������ �����';
$strCentralEuropean = '�����������������';
$strChange = '�������';
$strChangeCopyMode = '������� ����� ��������� �� ����� ������������ � ...';
$strChangeCopyModeCopy = '... ������ �����.';
$strChangeCopyModeDeleteAndReload = ' ... ������ ������ �� ������ ��������� � ����� ������ ����� ����������.';
$strChangeCopyModeJustDelete = ' ... ������ ����� �� ������ ���������.';
$strChangeCopyModeRevoke = ' ... �������� ��� ���������� ������ ��������� � ����� �� ������.';
$strChangeCopyUser = '������� ���������� � ������ / ������ ���������';
$strChangeDisplay = '������� ��� �� ������';
$strChangePassword = '������� �������';
$strCharset = '�������� ���';
$strCharsetOfFile = '�������� ��� ��������:';
$strCharsets = '����� ������';
$strCharsetsAndCollations = '�������� ������ � ���������';
$strCheckAll = '������ ���';
$strCheckOverhead = '������� ����������';
$strCheckPrivs = '������� ����������';
$strCheckPrivsLong = '������� ���������� �� ���� &quot;%s&quot;.';
$strCheckTable = '������� ������';
$strChoosePage = '��������� ������ ��� �����';
$strColComFeat = '��������� ��������� ������';
$strCollation = '���������';
$strColumnNames = '����� ������';
$strColumnPrivileges = '���������� ������ �� ������';
$strCommand = '�������';
$strComments = '���������';
$strCommentsForTable = '��������� ������';
$strCompatibleHashing = 'MySQL&nbsp;4.0 ������������';
$strCompleteInserts = '��������� INSERT (�� ������� ���)';
$strCompression = '���������';
$strConfigFileError = 'phpMyAdmin ��� ����� �� ������� ���� �������������� ��������!<br />��� �� ���� ������ ��� PHP ���� ������ � ����������� ��� �� ���� �� ������� ��������.<br />�������� �������������� �������� �������� �������� ��� ���� � ��������� ������ � ������ ��� �������. � ����� �������� ����� �������� �������� ��� �����-�����.<br />��� ������� ������ ������, ��� �� � ����.';
$strConfigureTableCoord = '�������� ���������� �� ������ %s';
$strConnectionError = '�� ���� �� �� �������: ���������� ����������.';
$strConnections = '��������';
$strConstraintsForDumped = '��������� �� �������� ������';
$strConstraintsForTable = '��������� �� ������';
$strCookiesRequired = '������� (Cookies) ����� � ���� ������ ���� �������.';
$strCopyDatabaseOK = '���� %s �� ����������� � %s';
$strCopyTable = '������ ������ � (����<b>.</b>������):';
$strCopyTableOK = '������ %s �� �������� � %s.';
$strCopyTableSameNames = '�� ���� �� ������� ������ � ���� ����!';
$strCouldNotKill = 'phpMyAdmin ��� ����� �� ������� ������ %s. ��������� �� �� ��������.';
$strCreate = '�������';
$strCreateIndex = '������� ��� ��&nbsp;%s&nbsp;������';
$strCreateIndexTopic = '������� ���� ���';
$strCreateNewDatabase = '������� ���� ���� ��������';
$strCreateNewTable = '������� ���� ������ � ���� %s';
$strCreatePage = '������� ���� ������';
$strCreatePdfFeat = '������ PDF-ova';
$strCreationDates = '������ ��������/���������/�������';
$strCriteria = '���������';
$strCroatian = '��������';
$strCyrillic = '���������';
$strCzech = '�����';
$strCzechSlovak = '�����-��������';

$strDBComment = '�������� ����:';
$strDBCopy = '������ ���� �';
$strDBGContext = '��������';
$strDBGContextID = '�������� ��';
$strDBGHits = '��������';
$strDBGLine = '�����';
$strDBGMaxTimeMs = 'Max �����, ��';
$strDBGMinTimeMs = '��� �����, ��';
$strDBGModule = '�����';
$strDBGTimePerHitMs = '�����/�������, ��';
$strDBGTotalTimeMs = '������ �����, ��';
$strDBRename = '�������� ���� �';
$strDanish = '������';
$strData = '������';
$strDataDict = '������ ��������';
$strDataOnly = '���� ������';
$strDatabase = '���� ��������';
$strDatabaseEmpty = '��� ���� ��� ������!';
$strDatabaseExportOptions = '����� �� ����� ����';
$strDatabaseHasBeenDropped = '���� %s �� ��������.';
$strDatabaseNoTable = '���� �� ������ ������!';
$strDatabases = '����';
$strDatabasesDropped = '%s ���� �� ������� ��������.';
$strDatabasesStats = '���������� ����';
$strDatabasesStatsDisable = '������ ����������';
$strDatabasesStatsEnable = '����� ����������';
$strDatabasesStatsHeavyTraffic = '��������: ��������� ���������� ���� ������������� ������ �������� ����� ��� � MySQL �������.';
$strDbPrivileges = '���������� ������ �� ����';
$strDbSpecific = '���������� �� ����';
$strDefault = '�������������';
$strDefaultValueHelp = '�� ������������� ��������, ������� ���� ����� ��������, ��� ����� ���� ��� ��������� � ���� ������: �';
$strDefragment = '������������� ������';
$strDelOld = '�������� ������ ��� ��������� �� ������ ��� ���� �� ������. ������ �� �� �������� �� ���������?';
$strDelayedInserts = '������� �������� �������';
$strDelete = '������';
$strDeleteAndFlush = '������ ��������� � ������ ����� ����������.';
$strDeleteAndFlushDescr = '��� �� �������� �����, ��� ������� ��������� ����������� ���� �� ������.';
$strDeleted = '��� �� �������';
$strDeletedRows = '�������� ������:';
$strDeleting = '������ %s';
$strDescending = '�������';
$strDescription = '����';
$strDictionary = '������';
$strDisableForeignChecks = '������ ������� ������� ������';
$strDisabled = '����������';
$strDisplayFeat = '������� �������';
$strDisplayOrder = '�������� �������:';
$strDisplayPDF = '������� PDF �����';
$strDoAQuery = '������� "���� �� �������" (�����: "%")';
$strDoYouReally = '�� �� ������� ����� �� ';
$strDocu = '������������';
$strDrop = '������';
$strDropDatabaseStrongWarning = '���� ���� �������� ��������� ���� ��������!';
$strDropSelectedDatabases = '������ �������� ����';
$strDropUsersDb = '������ ���� ��� �� ���� ���� ��� ���������.';
$strDumpSaved = '������ ���� �� ������� � �������� %s.';
$strDumpXRows = '������� %s ������ ������� �� ���� %s.';
$strDumpingData = '������ �������� ������';
$strDynamic = '���������';

$strEdit = '�������';
$strEditPDFPages = '�������� PDF ������';
$strEditPrivileges = '������� ����������';
$strEffective = '���������';
$strEmpty = '��������';
$strEmptyResultSet = 'MySQL �� ������ ������ �������� (���� ������).';
$strEnabled = '��������';
$strEncloseInTransaction = '����� ����� � ����������';
$strEnd = '���';
$strEndCut = '���� ���';
$strEndRaw = '���� ������';
$strEnglish = '��������';
$strEnglishPrivileges = ' ��������: MySQL ����� ���������� ����� �� ���� �� ��������� ';
$strError = '������';
$strEscapeWildcards = '��� ������ _ � % ����� ������� ���� \ ��� �� ��������� ����������';
$strEstonian = '��������';
$strExcelEdition = 'Excel ������';
$strExcelOptions = 'Excel �����';
$strExecuteBookmarked = '������ ������ ����';
$strExplain = '������ SQL';
$strExport = '�����';
$strExtendedInserts = '��������� INSERT';
$strExtra = '�������';

$strFailedAttempts = '��������� �������';
$strField = '���';
$strFieldHasBeenDropped = '��� %s �� ��������';
$strFields = '���';
$strFieldsEmpty = ' ��� ��� �� ����! ';
$strFieldsEnclosedBy = '��� ���������� ��';
$strFieldsEscapedBy = '����� �������� &nbsp; &nbsp; &nbsp;';
$strFieldsTerminatedBy = '��� ��������� ��';
$strFileAlreadyExists = '�������� %s �� ������ �� �������, ��������� ��� �������� ��� ������� ����� �����������.';
$strFileCouldNotBeRead = '�������� ��� ����� ���������';
$strFileNameTemplate = '������ ����� ��������';
$strFileNameTemplateHelp = '������� __DB__ �� ��� ����, __TABLE__ �� ��� ������  � %s���� ��� strftime%s ����� �� ������������ �������, � ��������� �� ���������� ���� ������. ��� ������ ����� ��� �������.';
$strFileNameTemplateRemember = '������� ������';
$strFixed = '������';
$strFlushPrivilegesNote = '��������: phpMyAdmin ����� ���������� ��������� �������� �� MySQL ������ ����������. ������ ��� ������ ���� �� ����������� �� ���������� ��� ������ ������� ��� �� ������ ����� ������. � ��� ������ %s������ ������� ����������%s ��� ���� ��� ���������.';
$strFlushTable = '������ ������ ("FLUSH")';
$strFormEmpty = '�������� �������� � �������!';
$strFormat = '������';
$strFullText = '��� �����';
$strFunction = '�������';

$strGenBy = '���������';
$strGenTime = '����� ��������';
$strGeneralRelationFeat = '����� ������� �������';
$strGeorgian = '��������';
$strGerman = '�������';
$strGlobal = '��������';
$strGlobalPrivileges = '�������� ����������';
$strGlobalValue = '�������� ��������';
$strGo = '�����';
$strGrantOption = '������';
$strGreek = '�����';
$strGzip = '"����-�����"';

$strHasBeenAltered = '�� �������(�).';
$strHasBeenCreated = '�� �������(�).';
$strHaveToShow = '������ �������� ��� ����� ������ �� ������';
$strHebrew = '��������';
$strHexForBinary = '������� �������������� �� ������� ���';
$strHome = '������� ������';
$strHomepageOfficial = 'phpMyAdmin ��� ���';
$strHost = '�������';
$strHostEmpty = '��� �������� �� ������!';
$strHungarian = '��������';

$strIcelandic = '���������';
$strId = 'ID';
$strIdxFulltext = '����� ���';
$strIfYouWish = '��� ������ �� ��������� ���� ���� ������ � ������, �������� �� ��������� �������';
$strIgnore = '��������';
$strIgnoreInserts = '�������� ��������� ��� �������';
$strIgnoringFile = '��������� �������� %s';
$strImportDocSQL = '���� docSQL ��������';
$strImportFiles = '���� ��������';
$strImportFinished = '���� �������';
$strInUse = '�� �������';
$strIndex = 'ʚ��';
$strIndexHasBeenDropped = 'ʚ�� %s �� �������';
$strIndexName = '��� ���� :';
$strIndexType = '��� ���� :';
$strIndexWarningMultiple = '���� �� ������ %s ���� �� ��������� �� ������ `%s`';
$strIndexWarningPrimary = 'PRIMARY � INDEX ������ �� �� ������� �� ���� ����������� ��������� �� ������ `%s`';
$strIndexWarningTable = '������� ��� ����������� ������ `%s`';
$strIndexWarningUnique = 'UNIQUE � INDEX ������ �� �� ������� �� ���� ����������� ��������� �� ������ `%s`';
$strIndexes = 'ʚ�����';
$strInnodbStat = 'InnoDB ������';
$strInsecureMySQL = '���� �������������� �������� ������ ���������� (root ��� �������) ��� ��������� ����������� MySQL �������������� ������. ��� MySQL ������ ���� �� ���� ������������, ������� �� �� �����, � ������ ����� �� ��������� ��� ���������� �����.';
$strInsert = '���� �����';
$strInsertAsNewRow = '����� ��� ���� ���';
$strInsertBookmarkTitle = '������ ������� ����� �������';
$strInsertNewRow = '����� ���� ���';
$strInsertTextfiles = '����� ������� �� ���������� ��������';
$strInsertedRowId = 'ID ��������� ������:';
$strInsertedRows = '������� ������:';
$strInstructions = '��������';
$strInternalNotNecessary = '* ��������� ������� ��� ��������� ���� ������ � � InnoDB.';
$strInternalRelations = '��������� �������';

$strJapanese = '��������';
$strJumpToDB = '���� �� ���� &quot;%s&quot;.';
$strJustDelete = '���� ������ ��������� �� ������ ����������.';
$strJustDeleteDescr = '&quot;��������&quot; ��������� �� � ���� ����� ������� ������� ��� ���������� �� ���� ������ �������.';

$strKeepPass = '���� �� ���� �������';
$strKeyname = '��� ����';
$strKill = '��������';
$strKorean = '�������';

$strLaTeX = 'LaTeX';
$strLaTeXOptions = 'LaTeX �����';
$strLandscape = '��������';
$strLatexCaption = '�������� ������';
$strLatexContent = '������ ������ __TABLE__';
$strLatexContinued = '(���������)';
$strLatexContinuedCaption = '�������� �������� ������';
$strLatexIncludeCaption = '����� �������� ������';
$strLatexLabel = '������ ����';
$strLatexStructure = '��������� ������ __TABLE__';
$strLatvian = '��������';
$strLengthSet = '������/��������*';
$strLimitNumRows = '��� ������ �� ������';
$strLineFeed = '������ �� ��� �����: \\n';
$strLinesTerminatedBy = '����� �� ��������� ��';
$strLinkNotFound = '���� ��� ���������';
$strLinksTo = '���� ��';
$strLithuanian = '���������';
$strLoadExplanation = '����� ����� �� �� �������, ��� �� ������ ��������� ��� �� ����.';
$strLoadMethod = 'LOAD �����';
$strLocalhost = '�������';
$strLocationTextfile = '������� ���������� ��������';
$strLogPassword = '�������:';
$strLogServer = '������';
$strLogUsername = '���������� ���:';
$strLogin = '����������';
$strLoginInformation = '������ � ������';
$strLogout = '���������';

$strMIMETypesForTable = 'MIME ������ �� ������';
$strMIME_MIMEtype = 'MIME-������';
$strMIME_available_mime = '�������� MIME-������';
$strMIME_available_transform = '�������� �������������';
$strMIME_description = '����';
$strMIME_nodescription = '���� ����� �� ��� �������������.<br />������ ������ ������ ��� %s ����.';
$strMIME_transformation = '������������ ������';
$strMIME_transformation_note = '�� ����� ��������� ����� ������������� � ������ ������������� MIME-������, �������� �� %s����� �������������%s';
$strMIME_transformation_options = '����� �������������';
$strMIME_transformation_options_note = '������ ������� ��������� �� ����� ������������� �������� ��� �����: \'a\',\'b\',\'c\'...<br />��� ����� �� ������� ������� ���� ���� ("\\") ��� �������� ("\'") � �� ���������, ������� ������� ���� ���� ������ ��� (�� ������ \'\\\\xyz\' ��� \'a\\\'b\').';
$strMIME_without = 'MIME-������ ��������� � ������� ����� ������� ������� �������������.';
$strMaximumSize = '���������� ��������: %s%s';
$strModifications = '������ �� ��������';
$strModify = '�������';
$strModifyIndexTopic = '������ ���';
$strMoreStatusVars = '��� ��������� ����������';
$strMoveTable = '������ ������ � (����<b>.</b>������):';
$strMoveTableOK = '������ %s �� �������� � %s.';
$strMoveTableSameNames = '�� ���� �� ��������� ������ � ���� ����!';
$strMultilingual = '����������';
$strMustSelectFile = '������ �������� �������� ��� ������ �� ��������.';
$strMySQLCharset = 'MySQL ��� ���������';
$strMySQLConnectionCollation = '��������� �� MySQL ����';
$strMySQLReloaded = 'MySQL ������ ��������.';
$strMySQLSaid = 'MySQL ����: ';
$strMySQLServerProcess = 'MySQL %pma_s1% �������� �� %pma_s2%, ������� ��� %pma_s3%';
$strMySQLShowProcess = '������� ����� �������';
$strMySQLShowStatus = '������� MySQL ���������� � ���� ����';
$strMySQLShowVars = '������� MySQL ��������� ���������';

$strName = '���';
$strNeedPrimaryKey = '������� �� �� ���������� �������� ��� �� ��� ������.';
$strNext = '������';
$strNo = '��';
$strNoActivity = '��� ���� ���������� %s ��� ���� �������, ������ �������� �� ������';
$strNoDatabases = '���� �� ������';
$strNoDatabasesSelected = '��� �������� �� ����� ����.';
$strNoDescription = '���� �����';
$strNoDropDatabases = '"DROP DATABASE" ������� �� ����������.';
$strNoExplain = '�������� ���������� SQL-a';
$strNoFrames = 'phpMyAdmin ��������� ������ ��� ��������� ������.';
$strNoIndex = 'ʚ�� ��� ���������!';
$strNoIndexPartsDefined = '������ ���� ���� ����������!';
$strNoModification = '���� ������';
$strNoOptions = '�� ������ ����� �� ��� ������';
$strNoPassword = '���� �������';
$strNoPermission = '��� ������� ��� �������� �� ������ �������� %s.';
$strNoPhp = '��� PHP ����';
$strNoPrivileges = '���� ����������';
$strNoQuery = '���� SQL �����!';
$strNoRights = '��� ��� �������� �� ������ ����!';
$strNoRowsSelected = '���� ��������� ������';
$strNoSpace = '�������� �������� �� ������� �������� %s.';
$strNoTablesFound = '������ ���� ��������� � ����.';
$strNoThemeSupport = '���� ������� �� ����, ������ ��������� ������������ �/��� ���� � ������������ %s.';
$strNoUsersFound = '�������� ��� �����.';
$strNoValidateSQL = '�������� ������� SQL-a';
$strNone = '����';
$strNotNumber = '��� ��� ���!';
$strNotOK = '��� � ����';
$strNotSet = '<b>%s</b> ������ ��� ��������� ��� ��� ��������� � %s';
$strNotValidNumber = '��� ���������� ��� ������!';
$strNull = 'Null';
$strNumSearchResultsInTable = '%s �������� ������ ������ <i>%s</i>';
$strNumSearchResultsTotal = '<b>������:</b> <i>%s</i> ��������';
$strNumTables = '������';

$strOK = '� ����';
$strOftenQuotation = '��������� ��� �� �������. ������� �� ����� �� ���� ��� ����, ��� �� ����� �� ���� ��� ������� ������.';
$strOperations = '��������';
$strOperator = '��������';
$strOptimizeTable = '�������� ������';
$strOptionalControls = '�������. ���� ��� �������� ���������� �������.';
$strOptionally = '�������';
$strOr = '���';
$strOverhead = '����������';
$strOverwriteExisting = '������� ������� ��������';

$strPHP40203 = '��������� PHP 4.2.3, ��� ��� ������ ��� �� ���������� ����������� (mbstring). ��������� ������� � ������ ��. 19404. ��� ������ PHP-a �� �� ���������� �� �������� �� phpMyAdmin.';
$strPHPVersion = '������ PHP-a';
$strPageNumber = '��� ������:';
$strPaperSize = '�������� ������';
$strPartialText = '��� ������';
$strPassword = '�������';
$strPasswordChanged = '������� �� %s �� ������� ��������.';
$strPasswordEmpty = '������� �� ������!';
$strPasswordHashing = '�������� �������';
$strPasswordNotSame = '������� ���� ���������!';
$strPdfDbSchema = '����� ���� "%s" - ������ %s';
$strPdfInvalidTblName = '������ "%s" �� ������!';
$strPdfNoTables = '���� ������';
$strPerHour = '�� ���';
$strPerMinute = '� ������';
$strPerSecond = '� �������';
$strPersian = '��������';
$strPhoneBook = '���������� ������';
$strPhp = '������� PHP ���';
$strPmaDocumentation = 'phpMyAdmin ������������';
$strPmaUriError = '<tt>$cfg[\'PmaAbsoluteUri\']</tt> ��������� ���� ���� �������� � �������������� ��������!';
$strPolish = '�����';
$strPortrait = '��������';
$strPos1 = '�������';
$strPrevious = '���������';
$strPrimary = '��������';
$strPrimaryKeyHasBeenDropped = '�������� ��� �� �������';
$strPrimaryKeyName = '��� ��������� ���� ���� �� ����... PRIMARY!';
$strPrimaryKeyWarning = '("PRIMARY" <b>����</b> ���� ��� <b>����</b> ��������� ����!)';
$strPrint = '������';
$strPrintView = '�� ������';
$strPrintViewFull = '������ �� ������ (�� ����� �������)';
$strPrivDescAllPrivileges = '������ ��� ���������� ���� GRANT.';
$strPrivDescAlter = '�������� ������ ��������� �������� ������.';
$strPrivDescCreateDb = '�������� �������� ����� ���� � ������.';
$strPrivDescCreateTbl = '�������� �������� ����� ������.';
$strPrivDescCreateTmpTable = '�������� �������� ����������� ������..';
$strPrivDescDelete = '�������� ������� ��������.';
$strPrivDescDropDb = '�������� ���������� ���� � ������.';
$strPrivDescDropTbl = '�������� ���������� ������.';
$strPrivDescExecute = '�������� ��������� ��������� ���������. ���� ������ � ��� ������ MySQL-a.';
$strPrivDescFile = '�������� ���� �������� � ����� ����� � ��������.';
$strPrivDescGrant = '�������� �������� ��������� � ���������� ��� �������� ��������� ������ ����������.';
$strPrivDescIndex = '�������� �������� � ������� ������.';
$strPrivDescInsert = '�������� ������� � ������ ��������.';
$strPrivDescLockTables = '�������� ���������� ������ ������ ���������.';
$strPrivDescMaxConnections = '���������� ��� ����� �������� ��� �������� ���� �� ������ �� ���.';
$strPrivDescMaxQuestions = '���������� ��� ����� ��� �������� ���� �� ����� ������� �� ���.';
$strPrivDescMaxUpdates = '���������� ��� ������� ��� ���� ������ ��� ���� ��� �������� ���� �� ������ �� ���.';
$strPrivDescProcess3 = '�������� ��������� ������� ������ ���������.';
$strPrivDescProcess4 = '�������� ������� ���������� ����� � ����� �������.';
$strPrivDescReferences = '���� ������ � ��� ������ MySQL-a.';
$strPrivDescReload = '�������� ������� ��������� ���������� ������� � ������ ���� �������.';
$strPrivDescReplClient = '��� ����� ��������� �� ���� ��� �� ������/������ �������.';
$strPrivDescReplSlave = '�������� ���� ������� ������� �� ����������.';
$strPrivDescSelect = '�������� ������ ��������.';
$strPrivDescShowDb = '��� ������� ��������� ����� ����.';
$strPrivDescShutdown = '�������� ����� �������.';
$strPrivDescSuper = ' �������� ���������� ���� �� ��������� ���������� ��� ��������� ����; ��������� �� ����� ���������������� ����� ��� ��� �� ���������� ��������� ���������� ��� ��������� ������� ������� ���������.';
$strPrivDescUpdate = '�������� ������ ��������.';
$strPrivDescUsage = '���� ����������.';
$strPrivileges = '����������';
$strPrivilegesReloaded = '���������� �� ������� ������ �������.';
$strProcesslist = '����� �������';
$strPutColNames = '����� ����� ��� � ���� ���';

$strQBE = '���� �� �������';
$strQBEDel = 'Del';
$strQBEIns = 'Ins';
$strQueryFrame = '������ �� �����';
$strQueryOnDb = 'SQL ���� �� ���� <b>%s</b>:';
$strQuerySQLHistory = 'SQL ��������';
$strQueryStatistics = '<b>���������� �����</b>: %s ����� �� ��������� ������� �� ������� ���������.';
$strQueryTime = '���� �� ����� %01.4f �������';
$strQueryType = '����� �����';
$strQueryWindowLock = '�� ������� ��� ���� ����� �������';

$strReType = '�������� ����';
$strReceived = '�������';
$strRecords = '������';
$strReferentialIntegrity = '������� ������������� ����������:';
$strRefresh = '������';
$strRelationNotWorking = '������� ��������� �� ��� �� ��������� �������� �� ��������. �� ����� ������� �����, �������� %s����%s.';
$strRelationView = '��������� ������';
$strRelationalSchema = '��������� �����';
$strRelations = '�������';
$strRelationsForTable = '�����ȣ� ������';
$strReloadFailed = '������� ��������� MySQL-a ��� ������.';
$strReloadMySQL = '������ ������� MySQL';
$strReloadingThePrivileges = '������ �������� ����������';
$strRemoveSelectedUsers = '������ �������� ���������';
$strRenameDatabaseOK = '���� %s �� ������������ � %s';
$strRenameTable = '������� ��� ������ � ';
$strRenameTableOK = '������ %s �������� ��� � %s';
$strRepairTable = '������� ������';
$strReplace = '������';
$strReplaceNULLBy = '������ NULL ��';
$strReplaceTable = '������ ������� � ������ �� �������� �� ��������';
$strReset = '�������';
$strResourceLimits = '��������� �������';
$strRevoke = '�������';
$strRevokeAndDelete = '�������� ��� ������� ���������� ��������� � ����� �� ������.';
$strRevokeAndDeleteDescr = '��������� �� � ���� ����� USAGE ���������� ��� �� ���������� ������ �� ������.';
$strRevokeMessage = '��������� ��� ���������� �� %s';
$strRomanian = '��������';
$strRowLength = '������ ����';
$strRowSize = '�������� ����';
$strRows = '������';
$strRowsFrom = ' ������ ����� �� ����';
$strRowsModeFlippedHorizontal = '������������� (�������� �������)';
$strRowsModeHorizontal = '�������������';
$strRowsModeOptions = '� %s ���� � ������ ������� ����� ������ %s ����';
$strRowsModeVertical = '�����������';
$strRowsStatistic = '���������� ����';
$strRunQuery = '������ SQL ����';
$strRunSQLQuery = '������ SQL ����(�) �� ���� %s';
$strRunning = '�� ������� %s';
$strRussian = '�����';

$strSQL = 'SQL';
$strSQLExportType = '��� ������';
$strSQLOptions = 'SQL �����';
$strSQLParserBugMessage = '������ �������� �� ��� �������� ��� � SQL �������. ������ �������� ��� ���� ������, � ��������� �� �� ��������� �������� � �� �� ��������. ������ ����� ������� ������ ���� ���� �� ��� ������� ������� �������� ��� ������� �� ������ �����. ������ ������� ��� ���� � MySQL ����� �������� �����. ��� ������ � ������ MySQL �������, ��� �� ���, ���� ��� ����� � ��������� ��������. ��� � ���� ����� �������� ��� ��� ������ �� ������ ���� ��� ������ ����� �������� �����, ������� ��� SQL ���� �� ����� ������ ���� ��� ������ �������� � �������� ��� ������� � ������ �� ����� ���� � ��� ��� ������:';
$strSQLParserUserError = '������� �� ������ ������ � ����� SQL �����. ���� �� ������ � ������ MySQL �������, ��� ��� ���� ����� � ��������� ��������';
$strSQLQuery = 'SQL ����';
$strSQLResult = 'SQL ��������';
$strSQPBugInvalidIdentifer = '���������� �ä�����������';
$strSQPBugUnclosedQuote = '�������� ��� ��������';
$strSQPBugUnknownPunctuation = '�������� ������ ������������';
$strSave = '������';
$strSaveOnServer = '������ �� ������ � ����������� %s';
$strScaleFactorSmall = '������ ������ �� ������� �� �� ����� ����� �� ����� ������';
$strSearch = '������������';
$strSearchFormTitle = '������������ ����';
$strSearchInTables = '������ ������:';
$strSearchNeedle = '���� ��� ��������� ��� �� ����� (�����: "%"):';
$strSearchOption1 = '��� ����� �� ����';
$strSearchOption2 = '��� ����';
$strSearchOption3 = '����� �����';
$strSearchOption4 = '��� ��������� �����';
$strSearchResultsFor = '��������� �������� �� "<i>%s</i>" %s:';
$strSearchType = '�����:';
$strSecretRequired = '�������������� �������� ������� ���� ������� (blowfish_secret).';
$strSelectADb = '��������� ����';
$strSelectAll = '������� ���';
$strSelectBinaryLog = '��������� ������� ������� �� �������';
$strSelectFields = '������� ��� (������ �����)';
$strSelectNumRows = '� �����';
$strSelectTables = '������� ������';
$strSend = '������ ��� ��������';
$strSent = '�������';
$strServer = '������';
$strServerChoice = '����� �������';
$strServerNotResponding = '������ �� ��������';
$strServerStatus = '���������� � ���� ����';
$strServerStatusUptime = '��� MySQL ������ ���� �� %s. �������� �� %s.';
$strServerTabProcesslist = '�������';
$strServerTabVariables = '���������';
$strServerTrafficNotes = '<b>�������� �������</b>: ������ ������� ���������� ������� ��������� �� ���� MySQL ������� �� ������� ���������.';
$strServerVars = '��������� ��������� � ����������';
$strServerVersion = '������ �������';
$strSessionValue = '�������� �����';
$strSetEnumVal = '��� �� ��� "enum" ��� "set", ������� ��������� � �������: \'a\',\'b\',\'c\'...<br />��� ��� ����� ������� ���� ���� ("\\") ��� �������� ("\'") ��������� �� � "����������" (escaped) ������ (�� ������ \'\\\\xyz\' ��� \'a\\\'b\').';
$strShow = '�������';
$strShowAll = '������� ���';
$strShowColor = '������� ���';
$strShowDatadictAs = '������ ������� ��������';
$strShowFullQueries = '������� ��������� �����';
$strShowGrid = '������� �����';
$strShowPHPInfo = '������� ���������� � PHP-�';
$strShowTableDimension = '������� �������� ������';
$strShowTables = '������� ������';
$strShowThisQuery = '������� ������ ��� ����';
$strShowingRecords = '������ ������';
$strSimplifiedChinese = '������������� �������';
$strSingly = '(�� ������ ���)';
$strSize = '��������';
$strSlovak = '��������';
$strSlovenian = '���������';
$strSort = '���������';
$strSortByKey = '������� �� ����';
$strSpaceUsage = '������';
$strSpanish = '�������';
$strSplitWordsWithSpace = '���� �� ������ �������� (" ").';
$strStatCheckTime = '������� �������';
$strStatCreateTime = '���������';
$strStatUpdateTime = '������� ������';
$strStatement = '���';
$strStatus = '������';
$strStrucCSV = 'CSV ������';
$strStrucData = '��������� � ������';
$strStrucDrop = '���� \'DROP TABLE\'';
$strStrucExcelCSV = 'CSV �� MS Excel';
$strStrucNativeExcel = '������� MS Excel ������';
$strStrucOnly = '���� ���������';
$strStructPropose = '�������� ��������� ������';
$strStructure = '���������';
$strSubmit = '������';
$strSuccess = '��� SQL ���� �� ������� �������';
$strSum = '������';
$strSwedish = '�������';
$strSwitchToDatabase = '������� �� �� �������� ����';
$strSwitchToTable = '���� �� �������� ������';

$strTable = '������';
$strTableComments = '��������� ������';
$strTableEmpty = '��� ������ �� ������!';
$strTableHasBeenDropped = '������ %s �� ��������';
$strTableHasBeenEmptied = '������ %s �� ���������';
$strTableHasBeenFlushed = '������ %s �� ��������';
$strTableMaintenance = '���� �� ������';
$strTableOfContents = '������';
$strTableOptions = '����� ������';
$strTableStructure = '��������� ������';
$strTableType = '��� ������';
$strTables = '%s ������';
$strTakeIt = '�������';
$strTblPrivileges = '���������� ������ �� ������';
$strTextAreaLength = '���� ������ ��������, ���<br />����� ����� ��� �� ��������';
$strThai = '�����';
$strTheContent = '������ �������� �� ����� � ����.';
$strTheContents = '������� �������� � ������ ������ �� �������� �� �������� ��� ���� ��������� �������� � ����������� (unique) ������.';
$strTheTerminator = '��������� ��� � ��������.';
$strTheme = '���� / ����';
$strThisHost = '��� ������';
$strThisNotDirectory = '��� ��� �����������';
$strThreadSuccessfullyKilled = '������ %s �� ������� ��������.';
$strTime = '�����';
$strToggleScratchboard = '�����/������ ����� �����';
$strTotal = '������';
$strTotalUC = '������';
$strTraditionalChinese = '������������� �������';
$strTraditionalSpanish = '������������� �������';
$strTraffic = '��������';
$strTransformation_application_octetstream__download = '�������� ���� �� ���������� �������� �������� �� ���. ���� ����� �� ��� ������� ��������. ����� ����� �� ����� ��� ��� ���� ������ ��� ������ ��� ��������. ��� ���� ����� �����, ���� ���� ���� ��������� �� ������ ������';
$strTransformation_image_jpeg__inline = '�������� ������� ����� �� ��� �� ����� ��������; �����: ������, ������ � ��������� (���� ���������� �����)';
$strTransformation_image_jpeg__link = '�������� ���� �� ��� ������ (���. �������� ���������� �� BLOB-�).';
$strTransformation_image_png__inline = '������� JPEG ����� �� ������';
$strTransformation_text_plain__dateformat = '����� TIME, TIMESTAMP ��� DATETIME ��� � ��������� �� �������� ������� ����� ����������� ������. ���� ����� �� ����� (� ������) ��� �� ����� ��������� ������ (�������������: 0). ����� ����� �� �������� ������ ������ ����� ����������� ��� �� �������� �� PHP-ov strftime().';
$strTransformation_text_plain__external = '���� LINUX: ������ �������� ��������� � ������� ������� � ����� ����� ����������� �����. ����� ���������� ����� ���������. ������������� �� Tidy, �� ����� ������ HTML ����. ���� ����������� �������, ������ ����� �������� �������� libraries/transformations/text_plain__external.inc.php � ������ ����� ��� ������ �� ���������. ���� ��ö�� �� ��� �������� ��� ������ �� ���������, � ����� �� ��������� ��������. ��� �� ���� ��������� ������� �� 1 ����� �� ���� ����������� �������� htmlspecialchars() (������������� �� 1). ��� �� ������� ��������� �������� �� 1, NOWRAP �� ���� ������ ����� �� �������� ���� �� �� ����� ���� �������� ��� ������. (������������� 1)';
$strTransformation_text_plain__formatted = '���� ���������� ����������� ���. Escaping �� �� ����.';
$strTransformation_text_plain__imagelink = '�������� ����� � ����, ��� ������ ����� ��������; ���� ����� �� ������� ��� "http://domain.com/", ����� ����� �� ������ � ���������, ���� �� ������.';
$strTransformation_text_plain__link = '�������� ����, ��� ������ ����� ��������; ���� ����� �� ������� ��� "http://domain.com/", ����� ����� �� ������ �� ����.';
$strTransformation_text_plain__substr = '������� ���� ��� �������. ���� ����� �� ����� ��� �������� ��� ����� ����� ����� ������ (������������� 0). ����� ����� �� ����� ��� ������� ������ �� ������ ���� ���������. ��� �� ����, ��� ��������� ����� �� ���� ��������. ���� ����� ������ ��� �� ����� ���� ������ ������ ���� �� ������� ��������� (�������������: ...) .';
$strTransformation_text_plain__unformatted = '�������� HTML ��� ��� HTML ��������. HTML ����������� �� �� ��������.';
$strTruncateQueries = '������� �������� �����';
$strTurkish = '������';
$strType = '���';

$strUkrainian = '���������';
$strUncheckAll = '������';
$strUnicode = '������';
$strUnique = '�����������';
$strUnknown = '��������';
$strUnselectAll = '�����';
$strUpdComTab = '������ ��������� � ������������ ���� �� ������� ������ Column_comments';
$strUpdatePrivMessage = '��������� ��� ���������� �� %s.';
$strUpdateProfileMessage = '������ �� �������.';
$strUpdateQuery = '������� ����';
$strUpgrade = '������� �� �� ���������� ��� %s ������ �� ������ %s ��� �����.';
$strUsage = '������';
$strUseBackquotes = '������� \' �� ������������ ����� ���';
$strUseHostTable = '������� ������ ��������';
$strUseTabKey = '��������� TAB ������ �� �������� �� ��� �� ���, ��� CTRL+�������� �� �������� ��������';
$strUseTables = '������� ������';
$strUseTextField = '������� ����� ���';
$strUseThisValue = '������� ��� ��������';
$strUser = '��������';
$strUserAlreadyExists = '�������� %s �� ������!';
$strUserEmpty = '��� ��������� ��� �����!';
$strUserName = '��� ���������';
$strUserNotFound = '�������� �������� ��� �������� � ������ ����������.';
$strUserOverview = '������� ���������';
$strUsersDeleted = '�������� ��������� �� ������� ��������.';
$strUsersHavingAccessToDb = '��������� ��� ���� ������� &quot;%s&quot;';

$strValidateSQL = '������� SQL';
$strValidatorError = 'SQL ��������� ��� ����� �� ���� ��������. ��������� �� �� �� ����������� ��������� PHP ��������� ������� �  %s������������%s.';
$strValue = '��������';
$strVar = '���������';
$strViewDump = '������� ������ (�����) ������';
$strViewDumpDB = '������� ������ (�����) ����';
$strViewDumpDatabases = '������� ������ (�����) ����';

$strWebServerUploadDirectory = '����������� �� ����� ��� ������� ';
$strWebServerUploadDirectoryError = '����������� ��� ��� �������� �� ����� ��� ��������';
$strWelcome = '���������� �� %s';
$strWestEuropean = '���������������';
$strWildcard = '�����';
$strWindowNotFound = '��������� ������ ������������ ��� ����� �� ���� ��������. ����� ��� ��������� ������� ������, ��� ��� ����������� ���������� ��������� ��� ��������� ���� ����������� ����������';
$strWithChecked = '��������:';
$strWritingCommentNotPossible = '������ ��������� ��� �����';
$strWritingRelationNotPossible = '��������� ������� ��� �����';
$strWrongUser = '�������� ���������� ���/�������. ������� ������.';

$strXML = 'XML';

$strYes = '��';

$strZeroRemovesTheLimit = '��������: ��������� ���� ����� �� 0 (����) ������ ���������.';
$strZip = '"��������"';

$strSQLExportCompatibility = 'SQL export compatibility';  //to translate
$strMbOverloadWarning = 'You have enabled mbstring.func_overload in your PHP configuration. This option is incompatible with phpMyAdmin and might cause breaking of some data!';  //to translate
$strMbExtensionMissing = 'The mbstring PHP extension was not found and you seem to be using multibyte charset. Without mbstring extension phpMyAdmin is unable to split strings correctly and it may result in unexpected results.';  //to translate
$strAfterInsertNext = 'Edit next row';  //to translate
?>
