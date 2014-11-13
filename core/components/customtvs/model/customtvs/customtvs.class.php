<?php

	/**
	 * Custom TVs
	 *
	 * Copyright 2013 by Oene Tjeerd de Bruin <info@oetzie.nl>
	 *
	 * This file is part of Custom TVs, a real estate property listings component
	 * for MODX Revolution.
	 *
	 * Custom TVs is free software; you can redistribute it and/or modify it under
	 * the terms of the GNU General Public License as published by the Free Software
	 * Foundation; either version 2 of the License, or (at your option) any later
	 * version.
	 *
	 * Custom TVs is distributed in the hope that it will be useful, but WITHOUT ANY
	 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
	 * A PARTICULAR PURPOSE. See the GNU General Public License for more details.
	 *
	 * You should have received a copy of the GNU General Public License along with
	 * Custom TVs; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
	 * Suite 330, Boston, MA 02111-1307 USA
	 */

	class CustomTVs {
		/**
		 * @acces public.
		 * @var Object.
		 */
		public $modx;
		
		/**
		 * @acces public.
		 * @var Array.
		 */
		public $config = array();
		
		/**
		 * @acces public.
		 * @param Object $modx.
		 * @param Array $config.
		*/
		function __construct(modX &$modx, array $config = array()) {
			$this->modx =& $modx;
		
			$corePath 		= $this->modx->getOption('customtvs.core_path', $config, $this->modx->getOption('core_path').'components/customtvs/');
			$assetsUrl 		= $this->modx->getOption('customtvs.assets_url', $config, $this->modx->getOption('assets_url').'components/customtvs/');
			$assetsPath 	= $this->modx->getOption('customtvs.assets_path', $config, $this->modx->getOption('assets_path').'components/customtvs/');
		
			$this->config = array_merge(array(
				'basePath'				=> $corePath,
				'corePath' 				=> $corePath,
				'modelPath' 			=> $corePath.'model/',
				'processorsPath' 		=> $corePath.'processors/',
				'elementsPath' 			=> $corePath.'elements/',
				'chunksPath' 			=> $corePath.'elements/chunks/',
				'pluginsPath' 			=> $corePath.'elements/plugins/',
				'snippetsPath' 			=> $corePath.'elements/snippets/',
				'tvsPath' 				=> $corePath.'elements/tvs/',
				'templatesPath' 		=> $corePath.'templates/',
				'helpurl'				=> 'customtvs'
			), $config);
		
			$this->modx->addPackage('customtvs', $this->config['modelPath']);
		}
		
		/**
		 * @acces public.
		 * @return String.
		 */
		public function getHelpUrl() {
			return $this->config['helpurl'];
		}
		
		/**
		 * @acces public.
		 * @param String $tpl.
		 * @param Array $properties.
		 * @param String $type.
		 * @return String.
		 */
		public function getTpl($tpl, $properties = array(), $type = 'chunk') {
		  	if (0 === strpos($tpl, '@')) {
			  	$type 	= substr($tpl, 1, strpos($tpl, ':') - 1);
			  	$tpl	= substr($tpl, strpos($tpl, ':') + 1, strlen($tpl));
		  	}
  
		  	switch (strtolower($type)) {
			  	case 'inline':
				  	$chunk = $this->modx->newObject('modChunk', array('name' => sprintf('customtvs-%s', uniqid())));
  
				  	$chunk->setCacheable(false);
  
				  	$output = $chunk->process($properties, $tpl);
  
				  	break;
			  	case 'chunk':
				  	$output = $this->modx->getChunk($tpl, $properties);
  
				  	break;
		  	}
  
		  	return $output;
	  	}
	}
	
?>