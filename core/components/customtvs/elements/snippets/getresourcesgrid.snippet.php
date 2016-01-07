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

	if (false !== ($tv = $modx->getOption('tv', $scriptProperties, false))) {
		$limit 		= $modx->getOption('limit', $scriptProperties, null);
		$resourceID = $modx->getOption('parent', $scriptProperties, $modx->resource->id);

		if (null !== ($resource = $modx->getObject('modResource', $resourceID))) {
			$templateVar = $resource->getTVValue(is_numeric($tv) ? (int) $tv : $tv);
			$templateVar = $modx->fromJSON('' == $templateVar ? '[]' : $templateVar);
			$order		 = $modx->getOption('order', $scriptProperties, 'idx');

			switch (strtoupper($order)) {
				case 'RAND':
					shuffle($templateVar);

					break;
				default:
					$templateVarSort = array();

					foreach($templateVar as $value) {
						if (isset($value[$order])) {
							$templateVarSort[$value[$order]] = $value;
						} else {
							$templateVarSort[$value['idx']] = $value;
						}
					}

					ksort($templateVarSort);

					if ('DESC' == strtoupper($modx->getOption('orderDir', $scriptProperties, 'ASC'))) {
						$templateVarSort = array_reverse($templateVarSort);
					}

					$templateVar = $templateVarSort;

					break;
			}

			$output 	= array();
			$tpl 		= $modx->getOption('tpl', $scriptProperties, null);

			foreach ($templateVar as $key => $value) {
				$output[] = $modx->getChunk($tpl, $value);

				if (null !== $limit && $limit <= count($output)) {
					break;
				}
			}

			if (0 < count($output)) {
				if (false === ($wrapper = $modx->getOption('tplWrapper', $scriptProperties, false))) {
					$output = implode(PHP_EOL, $output);
				} else {
					$output = $modx->getChunk($wrapper, array(
						'output' => implode(PHP_EOL, $output)
					));
				}

				if (false !== ($toPlaceholder = $modx->getOption('toPlaceholder', $scriptProperties, false))) {
					$modx->setPlaceholder($toPlaceholder, $output);
				} else {
					return $output;
				}
			}
		}
	}

	return;
	
?>