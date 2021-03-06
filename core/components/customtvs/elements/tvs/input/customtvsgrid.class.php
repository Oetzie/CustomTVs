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
			
			$this->modx->regClientStartupScript($this->customtvs->config['js_url'].'mgr/customtvsgrid.js');
			
			$placeholders = array(
				'formElements'		=> $this->modx->getOption('formelements', $params, '[]'),
				'gridElements'		=> $this->modx->getOption('gridelements', $params, '[]'),
				'gridSortCol'		=> $this->modx->getOption('gridsortcol', $params, 'idx'),
				'gridSortColDir'	=> $this->modx->getOption('gridsortcoldir', $params, 'ASC'),
				'gridSortable'		=> $this->modx->getOption('gridsortable', $params, false),
				'gridCreateType'	=> $this->modx->getOption('createtype', $params, false)
			);
			
			foreach ($placeholders as $key => $value) {
				$this->setPlaceholder($key, $value);
			}

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
			return $this->customtvs->config['templates_path'].'customtvsgrid.tpl';
		}
	}
	
	return 'CustomTVsGridInputRender';
	
?>