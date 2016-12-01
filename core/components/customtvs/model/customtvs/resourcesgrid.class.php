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

	require_once dirname( __FILE__ ).'/customtvs.class.php';

	class ResourcesGrid extends CustomTVs {
		/**
		 * @acces public.
		 * @param Array $scriptProperties.
		 * @return Boolean.
		 */
		public function setScriptProperties($scriptProperties = array()) {
			$this->properties = array_merge(array(
				'group'						=> false,
				'renders'					=> false,
				'limit'						=> 0,
				'sort'						=> '{"idx": "ASC"}',
				'tpls'						=> '{}'
			), $scriptProperties);

			return $this->setDefaultProperties();
		}
		
		/**
		 * @acces protected.
		 * @return Boolean.
		 */
		protected function setDefaultProperties() {
			if (is_string($this->properties['limit'])) {
				$this->properties['limit'] = (int) $this->properties['limit'];
			}
			
			if (is_string($this->properties['sort'])) {
				if (!in_array(strtoupper($this->properties['sort']), array('RAND', 'RAND()'))) {
					$this->properties['sort'] = $this->modx->fromJSON($this->properties['sort']);
				}
			}
			
			if (is_string($this->properties['tpls'])) {
				$this->properties['tpls'] = $this->modx->fromJSON($this->properties['tpls']);
			}
			
			if (!isset($this->properties['resource'])) {
				$this->properties['resource'] = $this->modx->resource->id;
			}

			return true;
		}
		
		/**
		 * @acces public.
		 * @param Array $properties.
		 * @return String.
		 */
		public function run($properties = array()) {
			$this->setScriptProperties($properties);
			
			if (isset($this->properties['tv'])) {
				$tv = is_numeric($this->properties['tv']) ? (int) $this->properties['tv'] : $this->properties['tv'];
				
				if (null !== ($resource = $this->modx->getObject('modResource', $this->properties['resource']))) {
					$tvValue = $resource->getTVValue($tv);
					$tvValue = $this->modx->fromJSON('' == $tvValue ? '[]' : $tvValue);
					
					if (is_array($this->properties['sort'])) {
						foreach ($this->properties['sort'] as $key => $value) {
							if (in_array(strtoupper($value), array('ASC', 'DESC'))) {
								$tvValueSort = array();
								
								foreach($tvValue as $tvSubValue) {
									if (isset($tvSubValue[$key])) {
										$tvValueSort[$tvSubValue[$key]] = $tvSubValue;
									} else {
										$tvValueSort[$tvSubValue['idx']] = $tvSubValue;
									}
								}
								
								ksort($tvValueSort);
								
								if ('DESC' == strtoupper($value)) {
									$tvValueSort = array_reverse($tvValueSort);
								}
								
								$tvValue = $tvValueSort;
							}
						}
					} else if (is_string($this->properties['sort'])) {
						if (in_array(strtoupper($this->properties['sort']), array('RAND', 'RAND()'))) {
							shuffle($tvValue);
						}
					}
					
					$current 	= 0;
					$output 	= array();
	
					foreach ($tvValue as $key => $value) {
						foreach ($value as $subKey => $subValue) {
							if (preg_match('/-replace$/si', $subKey)) {
								unset($value[$subKey]);
							} else {
								if ('content' == $subKey && isset($value['render'])) {
									if (false !== ($renders = $this->properties['renders'])) {
										$subValue = $this->modx->runSnippet($renders, array(
											'value' 	=> $subValue,
											'render'	=> $value['render']
										));
									}
								}
								
								if (is_array($subValue)) {
									$subValue = implode(',', $subValue);
								}
								
								$value[$subKey] = $subValue;
							}
						}
						
						$class = array();

						if (0 == $current) {
							$class[] = 'first';
						}
						
						if (count($tvValue) - 1 == $current || (0 != $this->properties['limit'] && $this->properties['limit'] - 1 == $current)) {
							$class[] = 'last';
						}
						
						$class[] = 0 == $current % 2 ? 'odd' : 'even';
						
						$tpl = $this->properties['tpl'];
						
						if (isset($this->properties['tpls'])) {
							$tpls = $this->properties['tpls'];
							
							if (isset($tpls['tplOdd']) && in_array('odd', $class)) {
								$tpl = $tpls['tplOdd'];
							}
							
							if (isset($tpls['tplEven']) && in_array('even', $class)) {
								$tpl = $tpls['tplEven'];
							}
							
							if (isset($tpls['tplFirst']) && in_array('first', $class)) {
								$tpl = $tpls['tplFirst'];
							}
							
							if (isset($tpls['tplLast']) && in_array('last', $class)) {
								$tpl = $tpls['tplLast'];
							}
							
							if (isset($tpls['tpl'.$key])) {
								$tpl = $tpls['tpl'.$key];
							}
							
							if (isset($this->properties['tplCondition'])) {
								$condition = $this->properties['tplCondition'];
								
								if (isset($value[$condition]) && isset($tpls[$value[$condition]])) {
									$tpl = $tpls[$value[$condition]];
								}
							}
						}
						
						if (false == $this->properties['group']) {
							$output[] = $this->getTemplate($tpl, array_merge(array(
								'idx'	=> $current,
								'class'	=> implode(' ', $class)
							), $value));
						} else {
							$group = 'no-group';
							
							if (isset($value[$this->properties['group']])) {
								$group = $value[$this->properties['group']];
								
								unset($value[$this->properties['group']]);
							}
							
							$output[$group][] = $this->getTemplate($tpl, array_merge(array(
								'idx'	=> $current,
								'class'	=> implode(' ', $class)
							), $value));
						}
		
						if (0 != $this->properties['limit'] && $this->properties['limit'] <= count($output)) {
							break;
						}
						
						$current++;
					}
					
					if (0 < count($output)) {
						if (false != $this->properties['group']) {
							foreach ($output as $key => $value) {
								$output[$key] = $this->getTemplate($this->properties['tplGroup'], array(
									'output'	=> implode(PHP_EOL, $value),
									$this->properties['group'] => $key
								));
							}	
						}
						
						if (isset($this->properties['tplWrapper'])) {
							$output = $this->getTemplate($this->properties['tplWrapper'], array(
								'output'	=> implode(PHP_EOL, $output)
							));
						} else {
							$output = implode(PHP_EOL, $output);
						}
						
						if (isset($this->properties['toPlaceholder'])) {
							$this->modx->setPlaceholder($this->properties['toPlaceholder'], $output);
						} else {
							return $output;
						}
					}
				}
			}
			
			if (isset($this->properties['tplWrapperEmpty'])) {
				return $this->getTemplate($this->properties['tplWrapperEmpty']);
			}
			
			return '';
		}
	}
	
?>