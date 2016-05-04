<?php  // Moodle configuration file

unset($CFG);
global $CFG;
$CFG = new stdClass();

$CFG->dbtype    = 'mariadb';
$CFG->dblibrary = 'native';
$CFG->dbhost    = 'db';
$CFG->dbname    = 'zll_moodle_1';
$CFG->dbuser    = 'moodle';
$CFG->dbpass    = 'yBDRf9iPCDyGFQjcEGTYhLswYFuWEMf6VDvyD4ZvE6kyzK7aYRJkh3dfQYUDeANd';
$CFG->prefix    = 'mdl_';
$CFG->dboptions = array (
  'dbpersist' => 0,
  'dbport' => '',
  'dbsocket' => '',
);

$CFG->wwwroot   = 'http://fizban03.rz.tu-harburg.de/moodle';
$CFG->dataroot  = '/var/www/moodledata';
$CFG->admin     = 'admin';

$CFG->directorypermissions = 0777;

//require_once(dirname(__FILE__) . '/lib/setup.php');
require_once('/var/www/html/moodle/lib/setup.php');

// There is no php closing tag in this file,
// it is intentional because it prevents trailing whitespace problems!
