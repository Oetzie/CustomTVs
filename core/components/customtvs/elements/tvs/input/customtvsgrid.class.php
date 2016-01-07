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
	 
	class CustomTVsGridInputRender extends modTemplateVarInputRender {
		/**
		 * @acces public.
		 * @var Object.
		 */
		public $customTVs = null;
		
		/**
		 * @acces public.
		 * @return Array.
		 */
		public function getLexiconTopics() {
			return array('customtvs:default');
		}
		
		/**
		 * @acces public.
		 * @param $value Mixed.
		 * @param $param Array.
		 * @return Mixed.
		 */
		public function process($value, array $params = array()) {
			$this->customTVs = $this->modx->getService('customtvs', 'CustomTVs', $this->modx->getOption('customtvs.core_path', null, $this->modx->getOption('core_path').'components/customtvs/').'model/customtvs/');

			$this->modx->controller->addLexiconTopic($this->modx->getOption('language', $this->customTVs->config));

			$this->modx->regClientStartupScript($this->modx->getOption('js_url', $this->customTVs->config).'mgr/customtvs.js');
			$this->modx->regClientStartupHTMLBlock('<script type="text/javascript">
				Ext.onReady(function() {
					CustomTVs.config = '.$this->modx->toJSON($this->customTVs->config).';
				});
			</script>');
			$this->modx->regClientStartupScript($this->modx->getOption('js_url', $this->customTVs->config).'mgr/customtvsgrid.js');
			
			$this->setPlaceholder('formElements', $this->modx->getOption('formelements', $params, '[]'));
			$this->setPlaceholder('gridElements', $this->modx->getOption('gridelements', $params, '[]'));
			$this->setPlaceholder('gridSortCol', $this->modx->getOption('gridsortcol', $params, 'idx'));
			$this->setPlaceholder('gridSortColDir', $this->modx->getOption('gridsortcoldir', $params, 'ASC'));
			$this->setPlaceholder('gridSortable', $this->modx->getOption('gridsortable', $params, false));
			$this->setPlaceholder('gridCreateType', $this->modx->getOption('createtype', $params, false));
			
			if ($this->modx->getOption('use_editor') && $richtext = $this->modx->getOption('which_editor')) {
				$properties = array(
					'editor' 	=> $richtext,
					'elements' 	=> array()
				);

				$onRichTextEditorInit = $this->modx->invokeEvent('OnRichTextEditorInit', $properties);
	            
	            if (is_array($onRichTextEditorInit)) {
					$onRichTextEditorInit = implode('', $onRichTextEditorInit);
            	}
            	
            	$this->setPlaceholder('onRichTextEditorInit', $onRichTextEditorInit);
			}
		}
		
		/**
		 * @acces public.
		 * @return String.
		 */
		public function getTemplate() {
			return $this->modx->getOption('templates_path', $this->customTVs->config).'customtvsgrid.tpl';
		}
	}
	
	return 'CustomTVsGridInputRender';
	
?>