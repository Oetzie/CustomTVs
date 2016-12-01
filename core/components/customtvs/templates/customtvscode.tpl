<textarea id="tv{$tv->id}" name="tv{$tv->id}" rows="15">{$tv->value}</textarea>

<script type="text/javascript">
// <![CDATA[
	{literal}
	Ext.onReady(function() {
		if ('Ace' == MODx.config.which_element_editor) {
			Ext.each(Ext.query('#tv{/literal}{$tv->id}{literal}'), function() {
				MODx.ux.Ace.replaceTextAreas([this], 'text/html', true);
			});
		} else {
			var fld = MODx.load({
	        	xtype		: 'textarea',
	        	applyTo		: 'tv{/literal}{$tv->id}{literal}',
				height		: 250,
				width		: '99%',
				enableKeyEvents: true,
				msgTarget	: 'under',
				allowBlank	: true,
				listeners	: {
					'keydown'	: {
						fn			: MODx.fireResourceFormChange,
						scope		:this
					}
				}
			});
			
			MODx.makeDroppable(fld);
			
			Ext.getCmp('modx-panel-resource').getForm().add(fld);
		}
	});
	{/literal}
// ]]>
</script>