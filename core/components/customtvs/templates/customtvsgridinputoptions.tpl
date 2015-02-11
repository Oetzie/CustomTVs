<div id="customtvs-{$tv}-properties-div"></div>

<script type="text/javascript">
// <![CDATA[
	{literal}
	var params = {
		{/literal}{foreach from=$params key=k item=v name='p'}
			'{$k}': '{$v|escape:"javascript"}'{if NOT $smarty.foreach.p.last},{/if}
		{/foreach}{literal}
	};
	
	var defaultFormElements = [
		'',
		'[{"xtype": "modx-combo-browser", "fieldLabel": "Image", "description": "Select the image for the carousel.", "name": "image", "anchor": "100%"},{"xtype": "textfield", "fieldLabel": "Name", "description": "Select the image alternative text.", "name": "name", "anchor": "100%", "allowBlank": false}]',
		'[{"xtype": "modx-combo-browser", "fieldLabel": "Image", "description": "Select the image for the carousel.", "name": "image", "anchor": "100%"},{"xtype": "textfield", "fieldLabel": "Name", "description": "Select the image alternative text.", "name": "name", "anchor": "100%", "allowBlank": false},{"xtype": "textarea", "fieldLabel": "Description", "description": "Select the image description.", "name": "description", "anchor": "100%", "allowBlank": true}]'
	];
	var defaultGridElements = [
		'',
		'[{"header" : "Image", "dataIndex" : "image", "width" : 150, "fixed" : true, "renderer" : "image"},{"header" : "Name", "dataIndex" : "name", "width" : 100}]',
		'[{"header" : "Image", "dataIndex" : "image", "width" : 150, "fixed" : true, "renderer" : "image"},{"header" : "Name", "dataIndex" : "name", "width" : 100}]'
	];
	
	var listeners = {
		'change'	: {
			fn			: function() {
				Ext.getCmp('modx-panel-tv').markDirty();
			},
			scope		: this
		}
	};
	
	MODx.load({
    	xtype		: 'panel',
    	layout		: 'form',
		cls			: 'form-with-labels',
		labelAlign	: 'top',
	    labelSeparator	: '',
		items		: [{
        	xtype			: 'modx-combo',
        	fieldLabel		: '{/literal}{$customtvs.label_default_elements}{literal}',
        	description		: MODx.expandHelp ? '' : '{/literal}{$customtvs.label_default_elements_desc}{literal}',
        	store			: new Ext.data.ArrayStore({
				fields			: ['value', 'label'],
				data			: [
					[0, ''],
					[1, '{/literal}{$customtvs.default_element_1}{literal}'],
					[2, '{/literal}{$customtvs.default_element_2}{literal}']
				]
			}),
			mode 			: 'local',
			name			: 'inopt_default_elements',
			hiddenName		: 'inopt_default_elements',
			valueField		: 'value',
			displayField	: 'label',
        	anchor			: '100%',
        	allowBlank		: true,
        	value			: params['default_elements'],
        	listeners		: Ext.applyIf({
	        	'select'		: {
	        		fn				: function(data) {
	        			Ext.getCmp('customtvs-{/literal}{$tv}{literal}-form-elements').setValue(defaultFormElements[data.value]);
	        			Ext.getCmp('customtvs-{/literal}{$tv}{literal}-grid-elements').setValue(defaultGridElements[data.value]);
					},
					scope		: this
				}
        	}, listeners)
        }, {
        	xtype			: MODx.expandHelp ? 'label' : 'hidden',
            html			: '{/literal}{$customtvs.label_default_elements_desc}{literal}',
            cls				: 'desc-under'
        }, {
        	xtype			: 'textarea',
        	fieldLabel		: '{/literal}{$customtvs.label_form_elements}{literal}',
        	description		: MODx.expandHelp ? '' : '{/literal}{$customtvs.label_form_elements_desc}{literal}',
        	name			: 'inopt_form_elements',
        	hiddenName		: 'inopt_form_elements',
        	id				: 'customtvs-{/literal}{$tv}{literal}-form-elements',
        	anchor			: '100%',
        	allowBlank		: false,
        	value			: params['form_elements'],
        	listeners		: listeners
        }, {
        	xtype			: MODx.expandHelp ? 'label' : 'hidden',
            html			: '{/literal}{$customtvs.label_form_elements_desc}{literal}',
            cls				: 'desc-under'
        }, {
        	xtype			: 'textarea',
        	fieldLabel		: '{/literal}{$customtvs.label_grid_elements}{literal}',
        	description		: MODx.expandHelp ? '' : '{/literal}{$customtvs.label_grid_elements_desc}{literal}',
        	name			: 'inopt_grid_elements',
        	hiddenName		: 'inopt_grid_elements',
        	id				: 'customtvs-{/literal}{$tv}{literal}-grid-elements',
        	anchor			: '100%',
        	allowBlank		: false,
        	value			: params['grid_elements'],
        	listeners		: listeners
        }, {
        	xtype			: MODx.expandHelp ? 'label' : 'hidden',
            html			: '{/literal}{$customtvs.label_grid_elements_desc}{literal}',
            cls				: 'desc-under'
        }, {
        	xtype			: 'combo-boolean',
        	fieldLabel		: '{/literal}{$customtvs.label_sortable}{literal}',
        	description		: MODx.expandHelp ? '' : '{/literal}{$customtvs.label_sortable_desc}{literal}',
			name			: 'inopt_grid_sortable',
			hiddenName		: 'inopt_grid_sortable',
        	anchor			: '60%',
        	allowBlank		: true,
        	value			: params['grid_sortable'],
        	listeners		: listeners
        }, {
        	xtype			: MODx.expandHelp ? 'label' : 'hidden',
            html			: '{/literal}{$customtvs.label_sortable_desc}{literal}',
            cls				: 'desc-under'
        }],
        renderTo: 'customtvs-{/literal}{$tv}{literal}-properties-div'
	});
	{/literal}
// ]]>
</script>