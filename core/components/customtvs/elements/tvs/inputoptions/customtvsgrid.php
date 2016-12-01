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
	
	$customtvs = $modx->getService('customtvs', 'CustomTVs', $modx->getOption('customtvs.core_path', null, $modx->getOption('core_path').'components/customtvs/').'model/customtvs/');

	if ($customtvs instanceof CustomTVs) {
		$modx->smarty->assign('customtvs', $modx->lexicon->fetch('customtvs.', true));
	
		return $modx->smarty->fetch($customtvs->config['templates_path'].'customtvsgridinputoptions.tpl');
	}
	
	return;
	
?>