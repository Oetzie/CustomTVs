<?php

	/**
	 * Custom TVs
	 *
	 * Copyright 2014 by Oene Tjeerd de Bruin <info@oetzie.nl>
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

	if (!function_exists('customTVsGridParseTemplate')) {
		function customTVsGridParseTemplate($tpl, $properties = array(), $type = 'chunk') {
			global $modx;
  
		  	if (0 === strpos($tpl, '@')) {
			  	$type 	= substr($tpl, 1, strpos($tpl, ':') - 1);
			  	$tpl	= substr($tpl, strpos($tpl, ':') + 1, strlen($tpl));
		  	}

		  	switch (strtolower($type)) {
			  	case 'inline':
				  	$chunk = $modx->newObject('modChunk', array('name' => sprintf('n-%s', uniqid())));
  
				  	$chunk->setCacheable(false);
  
				  	$output = $chunk->process($properties, $tpl);
  
				  	break;
			  	case 'chunk':
				  	$output = $modx->getChunk($tpl, $properties);

				  	break;
		  	}

		  	return $output;
	  	}
	}

	if (false !== ($tvID = $modx->getOption('tv', $scriptProperties, false))) {
		$limit = $modx->getOption('limit', $scriptProperties, null);

		if (null !== ($resource = $modx->getObject('modResource', $modx->getOption('parent', $scriptProperties, $modx->resource->id)))) {
			$templateVar = $resource->getTVValue(is_numeric($tvID) ? (int) $tvID : $tvID);

			$output = array();

			foreach ($modx->fromJSON('' != $templateVar ? $templateVar : '[]') as $key => $value) {
				$output[] = customTVsGridParseTemplate($modx->getOption('tpl', $scriptProperties, null), $value);

				if (null !== $limit && $limit <= count($output)) {
					break;
				}
			}

			if (0 < count($output)) {
				if (false == ($wrapper = $modx->getOption('tplWrapper', $scriptProperties, false))) {
					return implode(PHP_EOL, $output);
				} else {
					return customTVsGridParseTemplate($wrapper, array('output' => implode(PHP_EOL, $output)));
				}
			}
		}
	}
	
?>