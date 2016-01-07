{$onRichTextEditorInit}

<div id="customtvs-grid-panel-div-{$tv->id}">
	<input type="hidden" id="tv{$tv->id}" name="tv{$tv->id}" value="{$tv->value|escape}" />
</div>

<script type="text/javascript">
// <![CDATA[
	{literal}
	var customTV{/literal}{$tv->id}{literal} = Ext.onReady(function() {
		MODx.load({
			xtype			: 'customtvs-grid-panel-tv',
			renderTo		: 'customtvs-grid-panel-div-{/literal}{$tv->id}{literal}',
			tvid			: '{/literal}{$tv->id}{literal}',
			formElements	: Ext.decode('{/literal}{$formElements}{literal}'),
			gridElements	: Ext.decode('{/literal}{$gridElements}{literal}'),
			gridSortCol		: '{/literal}{$gridSortCol}{literal}',
			gridSortColDir	: '{/literal}{$gridSortColDir}{literal}',
			gridSortable	: '{/literal}{$gridSortable}{literal}',
			gridCreateType	: '{/literal}{$gridCreateType}{literal}',
			record			: '{/literal}{$record}{literal}'
		});
	});
	{/literal}
// ]]>
</script>