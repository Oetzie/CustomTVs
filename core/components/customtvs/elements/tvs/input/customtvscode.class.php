<?php

	/**
	 * Custom TVs
	 *
	 * Copyright 2016 by Oene Tjeerd de Bruin <info@oetzie.nl>
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
	 
	class CustomTVsCodeInputRender extends modTemplateVarInputRender {
		/**
		 * @acces public.
		 * @var Object.
		 */
		public $customtvs = null;
		
		/**
		 * @acces public.
		 * @param $value Mixed.
		 * @param $param Array.
		 * @return Mixed.
		 */
		public function process($value, array $params = array()) {
			$this->customtvs = $this->modx->getService('customtvs', 'CustomTVs', $this->modx->getOption('customtvs.core_path', null, $this->modx->getOption('core_path').'components/customtvs/').'model/customtvs/');

			$this->modx->regClientStartupScript($this->customtvs->config['js_url'].'mgr/customtvs.js');
			
			$this->modx->regClientStartupHTMLBlock('<script type="text/javascript">
				Ext.onReady(function() {
					CustomTVs.config = '.$this->modx->toJSON($this->customtvs->config).';
				});
			</script>');
			
			if (is_array($this->customtvs->config['lexicons'])) {
				foreach ($this->customtvs->config['lexicons'] as $lexicon) {
					$this->modx->controller->addLexiconTopic($lexicon);
				}
			} else {
				$this->modx->controller->addLexiconTopic($this->customtvs->config['lexicons']);
			}
		}
		
		/**
		 * @acces public.
		 * @return String.
		 */
		public function getTemplate() {
			return $this->customtvs->config['templates_path'].'customtvscode.tpl';
		}
	}
	
	return 'CustomTVsCodeInputRender';
	
?>