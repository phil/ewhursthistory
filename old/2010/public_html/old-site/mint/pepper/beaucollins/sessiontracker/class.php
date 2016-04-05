<?php
/******************************************************************************
 Pepper

 Developer      : Beau Collins
 Plug-in Name   : Session Tracker

 http://beaucollins.com/
 
 Copyright 2005 Beau Collins. This package cannot be redistributed without
 permission from http://beaucollins.com/

 You may contact the author at beaucollins@gmail.com
******************************************************************************/
$installPepper = "RHC3_SessionTracker";
 
class RHC3_SessionTracker extends Pepper{
	var $version    = 90;
	var $info       = array(
		'pepperName'    => 'Session Tracker',
		'pepperUrl'     => 'http://beaucollins.com/laboratory/mint-session-tracker/',
		'pepperDesc'    => 'Follows the trails left behind by your visitors.',
		'developerName' => 'Beau Collins',
		'developerUrl'  => 'http://beaucollins.com/'
	);
	var $panes = array (
   		'Session Tracker' => array (
        	'Active',
        	'New',
        	)
        );
	var $prefs = array(
		//user defined session timeout in minutes
		'sessiontimeout' => '5'
	);
	var $manifest = array(
		'visit' => array(
			'rhc3_sessiontracker_key' => 'VARCHAR(32)'
		)
	);
	var $data = array(
		'sessionkeytoken' => 'RHC3_MintSessionTrackerKey'
	);
	
	/********************************************************************
	update()
	- I'm an idiot so I need to add my token to the table field name as
	  well as the cookie, this should prevent us from losing all of our
	  session data.
	- Looks like it works! Kind of, err!
	********************************************************************/
	
	function update(){
		//change the manifest to reflect changes to db doesn't work
		$pepperID = $this->Mint->cfg['pepperLookUp']['RHC3_SessionTracker'];
		if($this->Mint->cfg['pepperShaker'][$pepperID]['version'] <= 3){
			$this->manifest = array(
				'visit' => array(
					'rhc3_sessiontracker_key' => 'VARCHAR (32)'
				)
			);
			//update the data property
			$this->data['sessionkeytoken'] = 'RHC3_MintSessionTrackerKey';


			//check if we have the old db field
			$describe = "DESCRIBE {$this->Mint->db['tblPrefix']}visit `sessiontracker_key`";
			$test = $this->query($describe);
			if(mysql_num_rows($test) > 0){
				$alter = "ALTER TABLE {$this->Mint->db['tblPrefix']}visit CHANGE `sessiontracker_key` `rhc3_sessiontracker_key` VARCHAR(32)";
				$this->query($alter);
			}

			foreach($this->Mint->cfg['manifest']['visit'] as $field => $pepper){
				if($field != 'sessiontracker_key'){
					$update[$field] = $pepper; 
				}else{
					$update['rhc3_sessiontracker_key'] = $pepper;
				}
			}
			$this->Mint->cfg['manifest']['visit'] = $update;				
			$this->Mint->cfg['pepperShaker'][$pepperID]['version'] = $this->version;
		}else{
			//anything past version 3 just make sure session_tracker is not in the manifest
			foreach($this->Mint->cfg['manifest']['visit'] as $field => $pepper){
				if($field != 'sessiontracker_key'){
					$update[$field] = $pepper; 
				}
			}
			$this->Mint->cfg['manifest']['visit'] = $update;			
			$this->Mint->cfg['pepperShaker'][$pepperID]['version'] = $this->version;
		}

		return true;
	}
	
	/********************************************************************
	onDisplayPreferences()
	-currently only one preference, sessiontimeout
	********************************************************************/
	
	function onDisplayPreferences(){
		$preferences['Session Timeout'] = <<<HERE
<table>
	<tr>
		<th scope="row">Session Timeout in Minutes</th>
		<td><span><input type="text" id="sessiontimeout" name="sessiontimeout" value="{$this->prefs['sessiontimeout']}" size="3" /></span></td>
	</tr>
</table>
HERE;
	return $preferences;
	}
	
	/********************************************************************
	onDisplayPreferences()
	- Saves the sessiontieout preference
	*********************************************************************/
	function onSavePreferences() 
	{
		$this->prefs['sessiontimeout']	= $this->escapeSQL($_POST['sessiontimeout']);
	}

	/********************************************************************
	isCompatible()
	- One requirement currently: Mint >= 1.2
	*********************************************************************/

	function isCompatible(){
		if($this->Mint->version >= 120){
			$key['isCompatible'] = true;
			$key['explanation'] = '<p>Session Tracker is friends with <a href="http://orderedlist.com/download/" title="Go to Orderedlist.com to get Download Counter">Download Counter</a>.</p>';
		}else{
			$key['isCompatible'] = false;
			$key['explanation'] = '<p>Session Tracker requires Mint 1.2 or higher.</p>';
		}
		return $key;
	}
	
	/********************************************************************
	onRecord()
	- Checks for sessionkey, if no session key, set new session key
	- Plan for javascript to set session key to true so we can tell wether or
	  not the browser accepts cookies
	*********************************************************************/
	
	function onRecord(){
		$sessionkey = $_COOKIE[$this->data['sessionkeytoken']];
		if($this->checkTimedOut(false, $sessionkey)){
			$sessionkey = $this->randomKeyGenerator();
			setcookie($this->data['sessionkeytoken'],$sessionkey);
		}
		if($sessionkey){
			$field['rhc3_sessiontracker_key'] = $sessionkey;
			return $field;
		}
	}
	
	/********************************************************************
	onDisplay()
	- New: display sessions as they are created
	- Active display sessions by idle time
	********************************************************************/

	function onDisplay($pane, $tab, $column = '', $sort = ''){
		$html = '';
		if($pane == 'Session Tracker'){
			switch($tab){
				case "New":
					$html .= $this->getHTML_NewSessions();
				break;
				case 'Active':
					$html .= $this->getHTML_ActiveSessions();
				break;
			}
		}
		return $html;
	}
	
	/********************************************************************
	onCustom()
	- Only one custom, getting table rows of sessions
	*********************************************************************/
	
	function onCustom(){
		if(
			isset($_POST['action'])	&&
			$_POST['action'] == 'showsession' &&
			isset($_POST['sessionkey'])
		){
			echo $this->getHTML_Session($_POST['sessionkey']);
		}

	}
	
	/********************************************************************
	getHTML_ActiveSession()
	- Called for Active view, returns a table of data with sessions ordered
	  by idle time
	*********************************************************************/

	function getHTML_ActiveSessions(){
		$html = '';
		$tableData['hasFolders'] = true;
		$tableData['table'] = array('id'=>'','class'=>'folder');
		$tableData['thead'] = array
		(
			array('value'=>'Browser','class'=>''),
			array('value'=>'Length','class'=>'')
		);
		
		$sessions = $this->getSessionsData('active');
		if(is_array($sessions)){
			foreach($sessions as $s){
				$sessionlabel = $this->formatSessionLabel($s);		
				if($s['views'] > 1){
					$duration = $this->formatTimeDuration($s['end']-$s['start']);
				}elseif($this->checkTimedOut($s['end'])){
					$duration = '<em>timed out</em>';
				}else{
					$duration = '<em>viewing</em>';
				}
				$tableData['tbody'][] = array(
					$sessionlabel,
					$duration,
					'folderargs' => array(
						'action'	=> 'showsession',
						'sessionkey'	=> $s['rhc3_sessiontracker_key']
					)
				);
			}
		}
		
		$html .= $this->Mint->generateTable($tableData);
		return $html;
	}
	
	/********************************************************************
	getHTML_NewSession()
	- Called for New view, shows sessions as they are created
	*********************************************************************/
	function getHTML_NewSessions(){
		$html = '';
		
		$tableData['hasFolders'] = true;
		
		$tableData['table'] = array('id'=>'','class'=>'folder');
		$tableData['thead'] = array
		(
			array('value'=>'Session','class'=>''),
			array('value'=>'Started','class'=>'')
		);
		
		$sessions = $this->getSessionsData('new');
		if(is_array($sessions)){
			foreach($sessions as $s){
				$session_label = $this->formatSessionLabel($s);
				
				$created = $this->Mint->formatDateTimeRelative($s['start']);
				
				$tableData['tbody'][] = array(
					$session_label,
					$created,
					'folderargs' =>array(
						'action'	=> 'showsession',
						'sessionkey'	=> $s['rhc3_sessiontracker_key']
					)
				);
			}
		}
		
		$html = $this->Mint->generateTable($tableData);
		return $html; 
	}
	
	/********************************************************************
	getHTML_Session()
	- Accepts one argument, the session key
	- Returns table rows of session page views
	*********************************************************************/
	function getHTML_Session($session_key){
		$records = $this->getSingleSessionData($session_key);
		for($i=0;$i<count($records);$i++){
			$lbl = ($i+1).' - '.$this->formatPageLabel($records[$i]);
			//if($records[$i+1][]){//if we're looking at a download next
			$offset = ($this->isDownload($records[$i+1]) && $records[$i+2]) ? 2 : 1 ; //we'll test if the next one is a download, and there's a record after
			
			if($this->isDownload($records[$i])){
				$img = $this->imgPath().'download.png';
				$duration = "<img style='text-align: center;' src='$img' alt='download'/>";
			}elseif($records[$i+$offset]){
				$start = $records[$i]['dt'];
				$end = $records[$i+$offset]['dt'];
				$duration = $this->formatTimeDuration($end-$start);
			}elseif($this->checkTimedOut($records[$i]['dt'])){
				$duration = '<em>timed out</em>';
			}else{
				$duration = '<em>viewing</em>';
			}
			
			$tableData['tbody'][] = array(
				$lbl,
				$duration
			);
			$count ++;
		}
		$html = $this->Mint->generateTableRows($tableData);
		return $html;
	}
	
	/*******************************************************************
	getSessionsData()
	- gets the data for the session view
	*******************************************************************/
	
	function getSessionsData($view = 'active'){
		$orderfield = ($view == 'active') ? 'end' : 'start' ;//end = last page view, start = created
		if($this->Mint->getPepperByClassName('SI_UserAgent')) $where = '';//select browser information
		
		$query = "SELECT *, COUNT(`id`) AS `views`, MIN(`dt`) AS `start`, MAX(`dt`) AS `end`
			FROM {$this->Mint->db['tblPrefix']}visit
			WHERE `rhc3_sessiontracker_key` IS NOT NULL
			GROUP BY `rhc3_sessiontracker_key`
			ORDER BY `$orderfield` DESC
			LIMIT 0, {$this->Mint->cfg['preferences']['rows']}";
			
		if($data = $this->query($query)){
			$sessions = array();
			while($r = mysql_fetch_assoc($data)){
				$sessions[] = $r;
			}
			return $sessions;			
		}else{
			return false;
		}
	}
				
	/********************************************************************
	getSingleSessionData()
	- Accepts session key
	- Queries for all of the page views for that session
	- used by getHTML_Session() method
	*********************************************************************/
	function getSingleSessionData($session_key){
		$query = "SELECT * FROM {$this->Mint->db['tblPrefix']}visit WHERE `rhc3_sessiontracker_key` = '$session_key' ORDER BY `dt` ASC";
		$data = $this->query($query);
		$results = array();
		while($r = mysql_fetch_assoc($data)){
			$results[] = $r;
		}
		return $results;
	}

	/********************************************************************
	formatTimeDuration()
	- Receives number of seconds
	- Returns length of time in readable format "1 min, 24 secs"
	- Pretty good for now
	*********************************************************************/
	function formatTimeDuration($seconds){
		$idle_secs = $seconds;
		$hours_idle = floor($seconds/3600);
		$idle_secs = $idle_secs - ($hours_idle * 3600);
		$minutes_idle = floor($idle_secs/60);
		$seconds_idle = $idle_secs - ($minutes_idle * 60);
		
		if($hours_idle > 0){
			$value = $hours_idle;
			$label = ($value == 1) ? "$value hour" : "$value hours";
			if($minutes_idle !=0) $label .= ($minutes_idle > 1) ? ", $minutes_idle mins" : ", 1 min";
		}elseif($minutes_idle > 0){
			$value = $minutes_idle;
			$label = ($value == 1) ? "$value min" : "$value mins";
			if($seconds_idle > 0) $label .= ($seconds_idle == 1) ? ', 1 sec' : ", $seconds_idle secs";
		}elseif($seconds_idle >= 1){
			$value = $seconds_idle;
			$label = ($value == 1) ? "$value sec" : "$value secs";
		}else{
			$label = "&lt; 1 sec";
		}
		//$label = "$hours_idle";
		return $label;
	}
	
	/********************************************************************
	formatSessionLabel()
	- Receives array of session data depending on if user agent is installed
	- Future, detect downloads (if steve smith updates his downloads plug-in)
	  Also detect outlicks, working on that with Andrew Sutherland
	*********************************************************************/

	function formatSessionLabel($s){
		$lbl = '<strong>'.$s['views'].(($s['views'] == 1) ? ' hit ' : ' hits ').'</strong>';
		if($s['browser_family']){
			$lbl .= ' with <strong>'.$s['browser_family'].'</strong> '.$s['browser_version'];//use browser family and version
		}else{
			$lbl .= ' from <strong>'.$s['ip_long'].'</strong>';
		}
		if(!$this->checkTimedOut($s['end'])){
			$activeimg = $this->imgPath().'active.png';
			$lbl.= " <img src='$activeimg' alt='active' />"; 
		}
		if($this->Mint->cfg['preferences']['secondary'] && $s['referer'] && $s['referer_is_local'] != 1){
			if(!$s['search_terms']){
				$ref = $this->Mint->abbr($s['referer'], 30);
				$lbl .= "<br/><span>From <a href='$s[referer]'>$ref</a></span>";
			}else{
				$ref = dirname($s['referer']);
				$ref = substr($ref, 7, strlen($ref)-7);
				$lbl .= "<br/><span>Search <a href='$s[referer]'>$ref</a> ($s[search_terms])</span>";
			}
		}
		
		return $lbl;
	}
	
	/********************************************************************
	formatPageLabel()
	- Kind of the same as formatSessionLabel, put for individual page
	  views
	*********************************************************************/
	function formatPageLabel($p){

		if(!$this->isDownload($p)){		
			$page_title = $this->Mint->abbr(($p['resource_title']) ? $p['resource_title'] : $p['resource'], 40);
			$lbl = "<a href=\"$p[resource]\">$page_title</a>";		
			if($this->Mint->cfg['preferences']['secondary'] && $p['referer_is_local'] != 1 && $p['referer']){
				if(!$p['search_terms']){
					$ref = $this->Mint->abbr($p['referer'], 30);
					$lbl .= "<br/><span>From <a href='$p[referer]'>$ref</a></span>";
				}else{
					$ref = dirname($p['referer']);
					$ref = substr($ref, 7, strlen($ref)-7);
					$lbl .= "<br/><span>Search <a href='$p[referer]'>$ref</a> ($p[search_terms])</span>";
				}
			}
		}else{
			$lbl = '<strong>Download:</strong> <abbr title="'.$p['resource'].'">'.basename($p['resource']).'</abbr>';
		}
		return $lbl;
	}
	
	/********************************************************************
	checkTimedOut()
	- Accepts dt and checks agains sessiontimeout
	- returns true if idle time exceeds sessiontimeout preference or false
	  if not
	*********************************************************************/
	function checkTimedOut($lastviewtime, $sessionkey=null){
		if($sessionkey && !$lastviewtime){
			$query = "SELECT `dt` FROM {$this->Mint->db['tblPrefix']}visit WHERE `rhc3_sessiontracker_key` = '$sessionkey' ORDER BY `dt` DESC LIMIT 1";
			if($data = $this->query($query)){
				$r = mysql_fetch_assoc($data);
				$lastviewtime = $r['dt'];
			}
		}elseif(!$sessionkey && !$lastviewtime){
			return true;
		}
		
		if($lastviewtime){
			if(time() - $lastviewtime < $this->prefs['sessiontimeout']*60){
				return false;
			}else{
				return true;
			}
		}else{
			return true;
		}
	}

	/********************************************************************
	randomKeyGenerator()
	- Uses remote ip, time, and a random number to generate the session key
	*********************************************************************/
	function randomKeyGenerator(){
		$ip = $_SERVER['REMOTE_ADDR'];
		$time = time();
		$random = rand();
		$key = $ip.$time.$random;
		return md5($key);
	}
		
	/********************************************************************
	isDownload()
	- Checks if page record is actually a download record
	- Hopefully we can update this to use `is_download` field
	*********************************************************************/

	function isDownload($p){
		if(strpos($p['resource_title'], 'Download: ') === 0) return true;
		return false;
	}
	
	/********************************************************************
	imgPath()
	- returns url path to images
	*********************************************************************/

	function imgPath(){
		$pepperID = $this->Mint->cfg['pepperLookUp']['RHC3_SessionTracker'];
		$pepperDat = $this->Mint->cfg['pepperShaker'][$pepperID];
		$path = $this->Mint->cfg['installFull'].'/'.dirname($pepperDat['src']).'/';
		return $path;
	}
}
 
 ?>