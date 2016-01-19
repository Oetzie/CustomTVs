<div id="customtvs-{$tv}-properties-div"></div>

<script type="text/javascript">
// <![CDATA[
	{literal}
	var params = {
		{/literal}{foreach from=$params key=k item=v name='p'}
			'{$k}': '{$v|escape:"javascript"}'{if NOT $smarty.foreach.p.last},{/if}
		{/foreach}{literal}
	};
	
	var defaultForms = [
		[0, '{/literal}{$customtvs.grid_default_0}{literal}', '[]', '[]'],
		[1, '{/literal}{$customtvs.grid_default_1}{literal}', '[{"idx":0,"xtype":"browser","name":"image","fieldLabel":"Afbeelding","description":"Selecteer een afbeelding.","anchor":"100%","required":true,"extra":{}},{"idx":1,"xtype":"textarea","name":"content","fieldLabel":"Omschrijving","description":"De omschrijving van de afbeelding.","anchor":"100%","required":true,"extra":{}}]', '[{"idx":0,"header":"Afbeelding","dataIndex":"image","width":"150","fixed":"true","sortable":false,"editable":false,"renderer":"image"},{"idx":1,"header":"Omschrijving","dataIndex":"content","width":"100","fixed":"","sortable":"","editable":"","renderer":""}]'],
		[2, '{/literal}{$customtvs.grid_default_2}{literal}', '[{"idx":0,"xtype":"browser","name":"image","fieldLabel":"Afbeelding","description":"Selecteer een afbeelding.","anchor":"100%","required":true,"extra":{}},{"idx":1,"xtype":"textarea","name":"content","fieldLabel":"Omschrijving","description":"De omschrijving van de afbeelding.","anchor":"100%","required":true,"extra":{}},{"idx":2,"xtype":"resource","name":"resource","fieldLabel":"Pagina","description":"Selecteer een pagina waar de afbeelding naar toe verwijst.","anchor":"100%","required":false,"extra":{}}]', '[{"idx":0,"header":"Afbeelding","dataIndex":"image","width":"150","fixed":"true","sortable":false,"editable":false,"renderer":"image"},{"idx":1,"header":"Omschrijving","dataIndex":"content","width":"100","fixed":"","sortable":"","editable":"","renderer":""}]'],
		[3, '{/literal}{$customtvs.grid_default_3}{literal}', '[{"idx":0,"xtype":"textfield","name":"title","fieldLabel":"Titel","description":"De titel.","anchor":"100%","required":true,"extra":{}},{"idx":1,"xtype":"textarea","name":"content","fieldLabel":"Omschrijving","description":"De omschrijving.","anchor":"100%","required":true,"extra":{}}]', '[{"idx":0,"header":"Titel","dataIndex":"title","width":"250","fixed":"true","sortable":false,"editable":false},{"idx":1,"header":"Omschrijving","dataIndex":"content","width":"100","fixed":"","sortable":"","editable":"","renderer":""}]']
	];
	
	var CustomTVs = function(config) {
		config = config || {};
		
		CustomTVs.superclass.constructor.call(this, config);
	};
	
	Ext.extend(CustomTVs, Ext.Component, {
		page	: {},
		window	: {},
		grid	: {},
		tree	: {},
		panel	: {},
		combo	: {},
		config	: {}
	});
	
	Ext.reg('customtvs', CustomTVs);
	
	CustomTVs = new CustomTVs();
	
	CustomTVs.grid.FormElements = function(config) {
	    config = config || {};
	    
	    this.store = new Ext.data.JsonStore({
	    	fields		: ['idx', 'xtype', 'name', 'fieldLabel', 'description', 'anchor', 'required', 'extra'],
			data		: Ext.decode(Ext.getCmp('customtvs-{/literal}{$tv}{literal}-formelements').getValue() || '[]'),
			remoteSort	: true
		});
	
		config.tbar = [{
	        text	: '{/literal}{$customtvs.grid_form_element_create}{literal}',
	        cls		:'primary-button',
	        handler	: this.createFormElement,
	        scope	: this
	   	}, '->', {
        	xtype			: 'modx-combo',
        	store			: new Ext.data.ArrayStore({
				fields			: ['value', 'label', 'form', 'grid'],
				data			: defaultForms
			}),
			mode 			: 'local',
			valueField		: 'value',
			displayField	: 'label',
			emptyText		: '{/literal}{$customtvs.grid_default_select}{literal}',
			width			: 300,
			listeners 		: {
				'select'		: function(event, record) {
					Ext.MessageBox.confirm('{/literal}{$customtvs.grid_default_title}{literal}', '{/literal}{$customtvs.grid_default_title_desc}{literal}', function(event) {
						if ('yes' == event) {
							Ext.getCmp('customtvs-grid-formelements').refreshData(Ext.decode(record.data.form || '[]'));
							Ext.getCmp('customtvs-grid-gridelements').refreshData(Ext.decode(record.data.grid || '[]'));
						}
					});
				}	
			}
        }];
	   	
	   	expander = new Ext.grid.RowExpander({
	        tpl : new Ext.Template(
	            '<p class="desc">{description}</p>'
	        )
	    });
	
	    columns = new Ext.grid.ColumnModel({
	        columns: [expander, {
	            header		: '{/literal}{$customtvs.grid_form_element_label_name}{literal}',
	            dataIndex	: 'name',
	            sortable	: false,
	            editable	: false,
	            width		: 200,
	            fixed		: true
	        }, {
	            header		: '{/literal}{$customtvs.grid_form_element_label_label}{literal}',
	            dataIndex	: 'fieldLabel',
	            sortable	: false,
	            editable	: false,
	            width		: 300,
	            fixed 		: false
	        }, {
	            header		: '{/literal}{$customtvs.grid_form_element_label_xtype}{literal}',
	            dataIndex	: 'xtype',
	            sortable	: false,
	            editable	: false,
	            width		: 200,
	            fixed		: true,
	            renderer 	: this.renderXtype
	        }]
	    });
	    
	    Ext.applyIf(config, {
	    	cm			: columns,
	        id			: 'customtvs-grid-formelements',
	        fields		: ['idx', 'xtype', 'name', 'fieldLabel', 'description', 'anchor', 'required', 'extra'],
	        paging		: false,
	        store		: this.store,
			autoHeight	: true,
			plugins		: expander,
			enableDragDrop : true,
			ddGroup 	: 'customtvs-grid-formelements', 
			tools		: [{
	            id			: 'plus',
	            qtip 		: _('expand_all'),
	            handler		: this.expandAll,
	            scope		: this
	        }, {
	            id			: 'minus',
	            hidden		: true,
	            qtip 		: _('collapse_all'),
	            handler		: this.collapseAll,
	            scope		: this
	        }],
	        listeners	: {
		    	'afteredit'	: {
		        	fn			: this.encodeData,
		        	scope		: this
		        },
		        'afterrender' : {
		           fn			: this.ddData,
		           scope		: this
		    	}
			}
	    });
	    
	    CustomTVs.grid.FormElements.superclass.constructor.call(this, config);
	};
	
	Ext.extend(CustomTVs.grid.FormElements, MODx.grid.LocalGrid, {
		refreshData: function(data) {
			this.getStore().loadData(data);
			this.encodeData();	
		},
		getMenu: function() {
		    return [{
			   	text	: '{/literal}{$customtvs.grid_form_element_update}{literal}',
			    handler	: this.updateFormElement,
			    scope	: this
			}, {
			   	text	: '{/literal}{$customtvs.grid_form_element_copy}{literal}',
			    handler	: this.copyFormElement,
			    scope	: this
			}, '-', {
				text	: '{/literal}{$customtvs.grid_form_element_remove}{literal}',
				handler	: this.removeFormElement,
				scope	: this
			}];
		},
		createFormElement: function(btn, e) {
	        if (this.createFormElementWindow) {
		        this.createFormElementWindow.destroy();
	        }
	        
	        this.createFormElementWindow = MODx.load({
		        xtype		: 'customtvs-window-formelement-create',
		        closeAction	: 'close',
		        scope		: this,
				listeners	: {
					'success'	: {
				    	fn			: this.encodeData,
						scope		: this
				    }
			    }
	        });
	        
	        this.createFormElementWindow.show(e.target);
	    },
	    updateFormElement: function(btn, e) {
			if (this.updateFormElementWindow) {
				this.updateFormElementWindow.destroy();
			}
			
			this.updateFormElementWindow = MODx.load({
				xtype			: 'customtvs-window-formelement-update',
				record			: this.menu.record,
				closeAction		:'close',
				scope			: this,
				listeners		: {
					'success'		: {
						fn				: this.encodeData,
						scope			: this
					}
				}
			});
			
			this.updateFormElementWindow.setValues(this.menu.record);
			this.updateFormElementWindow.show(e.target);
		},
		copyFormElement: function(btn, e) {
			var element = Ext.applyIf({
				name		: 'copy_' + this.menu.record.name,
				fieldLabel 	: '{/literal}{$customtvs.grid_copy}{literal} '+ this.menu.record.fieldLabel
			}, this.menu.record);
				
			this.getStore().loadData([element], true);
			this.encodeData();
		},
		removeFormElement: function(btn, e) {
	    	this.getStore().removeAt(this.menu.record.idx);
	    	this.encodeData();
	    },
	    encodeData: function() {
			var data = [];
	
		    for (i = 0; i <  this.getStore().data.length; i++) {
	 			var output = Ext.applyIf({
		 			idx : i
		 		}, this.getStore().data.items[i].data);

		 		data.push(output);
	        }
	        
	        Ext.getCmp('customtvs-{/literal}{$tv}{literal}-formelements').setValue(Ext.encode(data)); 
	
	        this.getStore().loadData(data);
	        this.getView().refresh();
		},
		ddData: function() {
		    var grid = this;
	
			var ddrow = new Ext.dd.DropTarget(this.getView().mainBody, {
	        	ddGroup 	: 'customtvs-grid-formelements',
	            notifyDrop 	: function(dd, e, data) {
	            	var sm = grid.getSelectionModel();
	                var sels = sm.getSelections();
	                var cindex = dd.getDragData(e).rowIndex;
	                
	                if (sm.hasSelection()) {
	                	for (i = 0; i < sels.length; i++) {
	                    	grid.getStore().remove(grid.getStore().getById(sels[i].id));
	                        grid.getStore().insert(cindex, sels[i]);
	                    }
	                    
	                    sm.selectRecords(sels);
	                    
	                    grid.encodeData();
	                }
	            }
	        });
		},
		renderXtype: function(a, b, c) {
			xtypes = {
				'textfield'		: '{/literal}{$customtvs.textfield}{literal}',
				'datefield'		: '{/literal}{$customtvs.datefield}{literal}',
				'timefield'		: '{/literal}{$customtvs.timefield}{literal}',
				'datetimefield'	: '{/literal}{$customtvs.datetimefield}{literal}',
				'passwordfield'	: '{/literal}{$customtvs.passwordfield}{literal}',
				'numberfield'	: '{/literal}{$customtvs.numberfield}{literal}',
	            'textarea'		: '{/literal}{$customtvs.textarea}{literal}',
	            'richtext'		: '{/literal}{$customtvs.richtext}{literal}',
	            'boolean'		: '{/literal}{$customtvs.boolean}{literal}',
	            'combo'			: '{/literal}{$customtvs.combo}{literal}',
	            'checkbox'		: '{/literal}{$customtvs.checkbox}{literal}',
	            'checkboxgroup'	: '{/literal}{$customtvs.checkboxgroup}{literal}',
	            'radiogroup'	: '{/literal}{$customtvs.radiogroup}{literal}',
	            'resource'		: '{/literal}{$customtvs.resource}{literal}',
	            'browser'		: '{/literal}{$customtvs.browser}{literal}',
			};

			return xtypes[a];            
		}
	});
	
	Ext.reg('customtvs-grid-formelements', CustomTVs.grid.FormElements);
	
	CustomTVs.window.CreateFormElement = function(config) {
	    config = config || {};
	    
	    Ext.applyIf(config, {
	    	autoHeight	: true,
	    	width		: 600,
	        title 		: '{/literal}{$customtvs.grid_form_element_create}{literal}',
	        defauls		: {
		        labelAlign	: 'top',
	            border		: false
	        },
	        fields		: [{
	            layout		: 'column',
	            border		: false,
	            defaults	: {
	                layout		: 'form',
	                labelSeparator : ''
	            },
	            items: [{
	                columnWidth: .85,
	                items		: [{
			        	xtype		: 'customtvs-combo-xtype',
			        	fieldLabel	: '{/literal}{$customtvs.grid_form_element_label_xtype}{literal}',
			        	description	: MODx.expandHelp ? '' : '{/literal}{$customtvs.grid_form_element_label_xtype_desc}{literal}',
			        	name		: 'xtype',
			        	anchor		: '100%',
			        	allowBlank	: false,
			        	listeners	: {
				        	'render'	: {
					        	fn 			: this.xtype,
					        	scope		: this
				        	},
				        	'select'	: {
					        	fn 			: this.xtype,
					        	scope		: this
				        	}
			        	}
			        }, {
			        	xtype		: MODx.expandHelp ? 'label' : 'hidden',
			            html		: '{/literal}{$customtvs.grid_form_element_label_xtype_desc}{literal}',
			            cls			: 'desc-under'
			        }]
			    }, {
			    	columnWidth: .15,
			    	style		: 'margin-right: 0;',
	                items		: [{
				        xtype		: 'checkbox',
			            fieldLabel	: '{/literal}{$customtvs.grid_form_element_label_required}{literal}',
			            description	: MODx.expandHelp ? '' : '',
			            name		: 'required',
			            inputValue	: true
			        }]
	            }]
			}, {
	            layout		: 'column',
	            border		: false,
	            style		: 'padding-top: 15px',
	            defaults	: {
	                layout		: 'form',
	                labelSeparator : ''
	            },
	            items: [{
	                columnWidth: .5,
	                items		: [{
			        	xtype		: 'textfield',
			        	fieldLabel	: '{/literal}{$customtvs.grid_form_element_label_name}{literal}',
			        	description	: MODx.expandHelp ? '' : '{/literal}{$customtvs.grid_form_element_label_name_desc}{literal}',
			        	name		: 'name',
			        	anchor		: '100%',
			        	allowBlank	: false
			        }, {
			        	xtype		: MODx.expandHelp ? 'label' : 'hidden',
			            html		: '{/literal}{$customtvs.grid_form_element_label_name_desc}{literal}',
			            cls			: 'desc-under'
			        }]
			    }, {
			    	columnWidth: .5,
			    	style		: 'margin-right: 0;',
	                items		: [{
			        	xtype		: 'textfield',
			        	fieldLabel	: '{/literal}{$customtvs.grid_form_element_label_label}{literal}',
			        	description	: MODx.expandHelp ? '' : '{/literal}{$customtvs.grid_form_element_label_label_label}{literal}',
			        	name		: 'fieldLabel',
			        	anchor		: '100%',
			        	allowBlank	: false
			        }, {
			        	xtype		: MODx.expandHelp ? 'label' : 'hidden',
			            html		: '{/literal}{$customtvs.grid_form_element_label_label_desc}{literal}',
			            cls			: 'desc-under'
			        }]
				}]
			}, {
	        	xtype		: 'textarea',
	        	fieldLabel	: '{/literal}{$customtvs.grid_form_element_label_description}{literal}',
	        	description	: MODx.expandHelp ? '' : '{/literal}{$customtvs.grid_form_element_label_description_desc}{literal}',
	        	name		: 'description',
	        	anchor		: '100%',
	        	height		: '30'
	        }, {
	        	xtype		: MODx.expandHelp ? 'label' : 'hidden',
	            html		: '{/literal}{$customtvs.grid_form_element_label_description_desc}{literal}',
	            cls			: 'desc-under'
	        }, {
		    	xtype		: 'fieldset',
		    	title		: '{/literal}{$customtvs.grid_extra_settings}{literal}',
				collapsible : true,
				collapsed 	: true,
				id			: 'customtvs-extra-settings-create',
				defaults	: {
	                layout		: 'form',
	                labelSeparator : ''
	            },
				items		: [{
				    xtype		: 'panel',
				    id 			: 'customtvs-extra-default-create',
				    style 		: 'padding-top: 2px',
				    hidden 		: false,
				    defaults	: {
		                layout		: 'form',
		                labelSeparator : ''
		            },
				    items		: [{
			        	xtype		: 'label',
			            html		: '{/literal}{$customtvs.grid_no_extra_settings}{literal}',
			            cls			: 'desc-under'
			        }]
				}, {
				    xtype		: 'panel',
				    id 			: 'customtvs-extra-datefield-create',
				    style 		: 'padding-top: 15px',
				    hidden 		: true,
				    defaults	: {
		                layout		: 'form',
		                labelSeparator : ''
		            },
				    items		: [{
			            layout		: 'column',
			            border		: false,
			            defaults	: {
			                layout		: 'form',
			                labelSeparator : ''
			            },
			            items: [{
			                columnWidth: .5,
			                items		: [{
					        	xtype		: 'datefield',
					        	fieldLabel	: '{/literal}{$customtvs.grid_form_element_label_mindate}{literal}',
					        	description	: MODx.expandHelp ? '' : '{/literal}{$customtvs.grid_form_element_label_mindate_desc}{literal}',
					        	name		: 'minDateValue',
					        	anchor		: '100%',
					        	format		: MODx.config.manager_date_format,
								startDay	: parseInt(MODx.config.manager_week_start)
					        }, {
					        	xtype		: MODx.expandHelp ? 'label' : 'hidden',
					            html		: '{/literal}{$customtvs.grid_form_element_label_mindate_desc}{literal}',
					            cls			: 'desc-under'
					        }]
					    }, {
					    	columnWidth: .5,
					    	style		: 'margin-right: 0;',
			                items		: [{
					        	xtype		: 'datefield',
					        	fieldLabel	: '{/literal}{$customtvs.grid_form_element_label_maxdate}{literal}',
					        	description	: MODx.expandHelp ? '' : '{/literal}{$customtvs.grid_form_element_label_maxdate_desc}{literal}',
					        	name		: 'maxDateValue',
					        	anchor		: '100%',
					        	format		: MODx.config.manager_date_format,
								startDay	: parseInt(MODx.config.manager_week_start)
					        }, {
					        	xtype		: MODx.expandHelp ? 'label' : 'hidden',
					            html		: '{/literal}{$customtvs.grid_form_element_label_maxdate_desc}{literal}',
					            cls			: 'desc-under'
					        }]
					    }]
					}]
				}, {
				    xtype		: 'panel',
				    id 			: 'customtvs-extra-timefield-create',
				    style 		: 'padding-top: 15px',
				    hidden 		: true,
				    defaults	: {
		                layout		: 'form',
		                labelSeparator : ''
		            },
				    items		: [{
			            layout		: 'column',
			            border		: false,
			            defaults	: {
			                layout		: 'form',
			                labelSeparator : ''
			            },
			            items: [{
			                columnWidth: .5,
			                items		: [{
					        	xtype		: 'timefield',
					        	fieldLabel	: '{/literal}{$customtvs.grid_form_element_label_mintime}{literal}',
					        	description	: MODx.expandHelp ? '' : '{/literal}{$customtvs.grid_form_element_label_mintime_desc}{literal}',
					        	name		: 'minTimeValue',
					        	anchor		: '100%',
					        	format		: MODx.config.manager_time_format
					        }, {
					        	xtype		: MODx.expandHelp ? 'label' : 'hidden',
					            html		: '{/literal}{$customtvs.grid_form_element_label_mintime_desc}{literal}',
					            cls			: 'desc-under'
					        }]
					    }, {
					    	columnWidth: .5,
					    	style		: 'margin-right: 0;',
			                items		: [{
					        	xtype		: 'timefield',
					        	fieldLabel	: '{/literal}{$customtvs.grid_form_element_label_maxtime}{literal}',
					        	description	: MODx.expandHelp ? '' : '{/literal}{$customtvs.grid_form_element_label_maxtime_desc}{literal}',
					        	name		: 'maxTimeValue',
					        	anchor		: '100%',
					        	format		: MODx.config.manager_time_format
					        }, {
					        	xtype		: MODx.expandHelp ? 'label' : 'hidden',
					            html		: '{/literal}{$customtvs.grid_form_element_label_maxtime_desc}{literal}',
					            cls			: 'desc-under'
					        }]
					    }]
					}]
				}, {
				    xtype		: 'panel',
				    id 			: 'customtvs-extra-richtext-create',
				    style 		: 'padding-top: 15px',
				    hidden 		: true,
				    defaults	: {
		                layout		: 'form',
		                labelSeparator : ''
		            },
				    items		: [{
			            layout		: 'column',
			            border		: false,
			            defaults	: {
			                layout		: 'form',
			                labelSeparator : ''
			            },
			            items: [{
			                columnWidth: .5,
			                items		: [{
					        	xtype		: 'textfield',
					        	fieldLabel	: '{/literal}{$customtvs.grid_form_element_label_toolbar1}{literal}',
					        	description	: MODx.expandHelp ? '' : '{/literal}{$customtvs.grid_form_element_label_toolbar1_desc}{literal}',
					        	name		: 'toolbar1',
					        	anchor		: '100%',
					        	value		: 'undo redo | bold italic underline strikethrough | styleselect bullist numlist outdent indent'
					        }, {
					        	xtype		: MODx.expandHelp ? 'label' : 'hidden',
					            html		: '{/literal}{$customtvs.grid_form_element_label_toolbar1_desc}{literal}',
					            cls			: 'desc-under'
					        }, {
					        	xtype		: 'textfield',
					        	fieldLabel	: '{/literal}{$customtvs.grid_form_element_label_toolbar3}{literal}',
					        	description	: MODx.expandHelp ? '' : '{/literal}{$customtvs.grid_form_element_label_toolbar3_desc}{literal}',
					        	name		: 'toolbar3',
					        	anchor		: '100%',
					        	value		: ''
					        }, {
					        	xtype		: MODx.expandHelp ? 'label' : 'hidden',
					            html		: '{/literal}{$customtvs.grid_form_element_label_toolbar3_desc}{literal}',
					            cls			: 'desc-under'
					        }]
					    }, {
					    	columnWidth: .5,
					    	style		: 'margin-right: 0;',
			                items		: [{
					        	xtype		: 'textfield',
					        	fieldLabel	: '{/literal}{$customtvs.grid_form_element_label_toolbar2}{literal}',
					        	description	: MODx.expandHelp ? '' : '{/literal}{$customtvs.grid_form_element_label_toolbar2_desc}{literal}',
					        	name		: 'toolbar2',
					        	anchor		: '100%',
					        	value		: ''
					        }, {
					        	xtype		: MODx.expandHelp ? 'label' : 'hidden',
					            html		: '{/literal}{$customtvs.grid_form_element_label_toolbar2_desc}{literal}',
					            cls			: 'desc-under'
					        }, {
					        	xtype		: 'textfield',
					        	fieldLabel	: '{/literal}{$customtvs.grid_form_element_label_plugins}{literal}',
					        	description	: MODx.expandHelp ? '' : '{/literal}{$customtvs.grid_form_element_label_plugins_desc}{literal}',
					        	name		: 'plugins',
					        	anchor		: '100%',
					        	value		: ''
					        }, {
					        	xtype		: MODx.expandHelp ? 'label' : 'hidden',
					            html		: '{/literal}{$customtvs.grid_form_element_label_plugins_desc}{literal}',
					            cls			: 'desc-under'
					        }]
					    }]
					}]
				}, {
				    xtype		: 'customtvs-combo-values',
				    id 			: 'customtvs-extra-combos-create',
				    style 		: 'padding-top: 15px',
				    hidden 		: true,
				    defaults	: {
		                layout		: 'form',
						labelSeparator : ''
		            }
				}, {
				    xtype		: 'panel',
				    id 			: 'customtvs-extra-browser-create',
				    style 		: 'padding-top: 15px',
				    hidden 		: true,
				    defaults	: {
		                layout		: 'form',
		                labelSeparator : ''
		            },
				    items		: [{
			            layout		: 'column',
			            border		: false,
			            defaults	: {
			                layout		: 'form',
			                labelSeparator : ''
			            },
			            items: [{
			                columnWidth: .5,
			                items		: [{
					        	xtype		: 'modx-combo-source',
					        	fieldLabel	: '{/literal}{$customtvs.grid_form_element_label_source}{literal}',
					        	description	: MODx.expandHelp ? '' : '{/literal}{$customtvs.grid_form_element_label_source_desc}{literal}',
					        	name		: 'source',
					        	anchor		: '100%',
					        	value 		: MODx.config.default_media_source
					        }, {
					        	xtype		: MODx.expandHelp ? 'label' : 'hidden',
					            html		: '{/literal}{$customtvs.grid_form_element_label_source_desc}{literal}',
					            cls			: 'desc-under'
					        }, {
					        	xtype		: 'textfield',
					        	fieldLabel	: '{/literal}{$customtvs.grid_form_element_label_filetypes}{literal}',
					        	description	: MODx.expandHelp ? '' : '{/literal}{$customtvs.grid_form_element_label_filetypes_desc}{literal}',
					        	name		: 'allowedFileTypes',
					        	anchor		: '100%',
					        	value		: ''
					        }, {
					        	xtype		: MODx.expandHelp ? 'label' : 'hidden',
					            html		: '{/literal}{$customtvs.grid_form_element_label_filetypes_desc}{literal}',
					            cls			: 'desc-under'
					        }]
					    }, {
					    	columnWidth: .5,
					    	style		: 'margin-right: 0;',
			                items		: [{
					        	xtype		: 'textfield',
					        	fieldLabel	: '{/literal}{$customtvs.grid_form_element_label_opento}{literal}',
					        	description	: MODx.expandHelp ? '' : '{/literal}{$customtvs.grid_form_element_label_opento_desc}{literal}',
					        	name		: 'openTo',
					        	anchor		: '100%',
					        	value		: '/'
					        }, {
					        	xtype		: MODx.expandHelp ? 'label' : 'hidden',
					            html		: '{/literal}{$customtvs.grid_form_element_label_opento_desc}{literal}',
					            cls			: 'desc-under'
					        }]
					    }]
					}]
				}]
		    }]
	    });
	    
	    CustomTVs.window.CreateFormElement.superclass.constructor.call(this, config);
	};
	
	Ext.extend(CustomTVs.window.CreateFormElement, MODx.Window, {
		xtype: function(event) {
			var type = 'create';
			
			var elements = {
				default 		: true,
				datefield 		: false,
				timefield 		: false,
				datetimefield	: false,
				richtext		: false,
				combos			: false,
				browser			: false
			};
			
			switch (event.value) {
				case 'datefield':
					elements.default 	= false;
					elements.datefield 	= true;
					
					break;	
				case 'timefield':
					elements.default 	= false;
					elements.timefield 	= true;
					
					break;
				case 'datetimefield':
					elements.default 	= false;
					elements.datefield 	= true;
					elements.timefield 	= true;
					
					break;
				case 'combo':
				case 'radiogroup':
				case 'checkboxgroup':
					elements.default 	= false;
					elements.combos 	= true;
					
					break;
				case 'richtext':
					elements.default 	= false;
					elements.richtext 	= true;
					
					break;
				case 'browser':
					elements.default 	= false;
					elements.browser 	= true;
					
					break;
			}
			
			if (!elements.default) {
				if (undefined !== (cmp = Ext.getCmp('customtvs-extra-settings-' + type))) {
					cmp.expand();
				}
			} else {
				if (undefined !== (cmp = Ext.getCmp('customtvs-extra-settings-' + type))) {
					cmp.collapse();
				}
			}

			for (element in elements) {
				if (undefined !== (elementCmp = Ext.getCmp('customtvs-extra-' + element + '-' + type))) {
					if (elements[element]) {
						elementCmp.show();
					} else {
						elementCmp.hide();
					}
				}
			}
		},
		submit: function(close) {
		    close = close === false ? false : true;
		        
		    var f = this.fp.getForm();

		    if (f.isValid() && this.fireEvent('beforeSubmit', f.getValues())) {
			    var element = {
					xtype 		: f.getValues().xtype,
					name 		: f.getValues().name,
					fieldLabel	: f.getValues().fieldLabel,
					description : f.getValues().description,
					anchor 		: '100%',
					required	: Boolean(f.getValues().required),
					extra 		: {}
				};
			    
			    switch (f.getValues().xtype) {
					case 'datefield':
						element.extra = Ext.applyIf({
							minDateValue	: f.getValues().minDateValue,
							maxDateValue	: f.getValues().maxDateValue,
						}, element.extra);
						
						break;
					case 'timefield':
						element.extra = Ext.applyIf({
							minTimeValue	: f.getValues().minTimeValue,
							maxTimeValue	: f.getValues().maxTimeValue
						}, element.extra);
						
						break;
					case 'datetimefield':
						element.extra = Ext.applyIf({
							minDateValue	: f.getValues().minDateValue,
							maxDateValue	: f.getValues().maxDateValue,
							minTimeValue	: f.getValues().minTimeValue,
							maxTimeValue	: f.getValues().maxTimeValue
						}, element.extra);
						
						break;
					case 'richtext':
						element.extra = Ext.applyIf({
							toolbar1		: f.getValues().toolbar1,
							toolbar2		: f.getValues().toolbar2,
							toolbar3		: f.getValues().toolbar3,
							plugins			: f.getValues().plugins
						}, element.extra);
						
						break;
					case 'combo':
					case 'checkboxgroup':
					case 'radiogroup':
						element.extra = Ext.applyIf({
							values	: Ext.decode(f.getValues().values || '[]')
						}, element.extra);

						break;
					case 'browser':
						element.extra = Ext.applyIf({
							source				: f.getValues().source,
							openTo				: f.getValues().openTo,
							allowedFileTypes	: f.getValues().allowedFileTypes
						}, element.extra);
						
						break;
				}
			
			    this.config.scope.getStore().loadData([element], true);

		        if (this.config.success) {
		            Ext.callback(this.config.success, this.config.scope || this, [f]);
		        }
		
		        if (this.fireEvent('success', f)) {
			    	if (close) {
		        		this.config.closeAction !== 'close' ? this.hide() : this.close();
					}
		       	}
			}
		}
	});
	
	Ext.reg('customtvs-window-formelement-create', CustomTVs.window.CreateFormElement);
	
	CustomTVs.window.UpdateFormElement = function(config) {
	    config = config || {};
	    
	    Ext.applyIf(config, {
	    	autoHeight	: true,
	    	width		: 600,
	        title 		: '{/literal}{$customtvs.grid_form_element_update}{literal}',
	        defauls		: {
		        labelAlign	: 'top',
	            border		: false
	        },
	        fields		: [{
		    	'xtype'		: 'hidden',
				'name'		: 'idx'
		    }, {
	            layout		: 'column',
	            border		: false,
	            defaults	: {
	                layout		: 'form',
	                labelSeparator : ''
	            },
	            items: [{
	                columnWidth: .85,
	                items		: [{
			        	xtype		: 'customtvs-combo-xtype',
			        	fieldLabel	: '{/literal}{$customtvs.grid_form_element_label_xtype}{literal}',
			        	description	: MODx.expandHelp ? '' : '{/literal}{$customtvs.grid_form_element_label_xtype_desc}{literal}',
			        	name		: 'xtype',
			        	anchor		: '100%',
			        	allowBlank	: false,
			        	listeners	: {
				        	'render'	: {
					        	fn 			: this.xtype,
					        	scope		: this
				        	},
				        	'select'	: {
					        	fn 			: this.xtype,
					        	scope		: this
				        	}
			        	}
			        }, {
			        	xtype		: MODx.expandHelp ? 'label' : 'hidden',
			            html		: '{/literal}{$customtvs.grid_form_element_label_xtype_desc}{literal}',
			            cls			: 'desc-under'
			        }]
			    }, {
			    	columnWidth: .15,
			    	style		: 'margin-right: 0;',
	                items		: [{
				        xtype		: 'checkbox',
			            fieldLabel	: '{/literal}{$customtvs.grid_form_element_label_required}{literal}',
			            description	: MODx.expandHelp ? '' : '',
			            name		: 'required',
			            inputValue	: true
			        }]
	            }]
			}, {
	            layout		: 'column',
	            border		: false,
	            style		: 'padding-top: 15px',
	            defaults	: {
	                layout		: 'form',
	                labelSeparator : ''
	            },
	            items: [{
	                columnWidth: .5,
	                items		: [{
			        	xtype		: 'textfield',
			        	fieldLabel	: '{/literal}{$customtvs.grid_form_element_label_name}{literal}',
			        	description	: MODx.expandHelp ? '' : '{/literal}{$customtvs.grid_form_element_label_name_desc}{literal}',
			        	name		: 'name',
			        	anchor		: '100%',
			        	allowBlank	: false
			        }, {
			        	xtype		: MODx.expandHelp ? 'label' : 'hidden',
			            html		: '{/literal}{$customtvs.grid_form_element_label_name_desc}{literal}',
			            cls			: 'desc-under'
			        }]
			    }, {
			    	columnWidth: .5,
			    	style		: 'margin-right: 0;',
	                items		: [{
			        	xtype		: 'textfield',
			        	fieldLabel	: '{/literal}{$customtvs.grid_form_element_label_label}{literal}',
			        	description	: MODx.expandHelp ? '' : '{/literal}{$customtvs.grid_form_element_label_label_desc}{literal}',
			        	name		: 'fieldLabel',
			        	anchor		: '100%',
			        	allowBlank	: false
			        }, {
			        	xtype		: MODx.expandHelp ? 'label' : 'hidden',
			            html		: '{/literal}{$customtvs.grid_form_element_label_label_desc}{literal}',
			            cls			: 'desc-under'
			        }]
				}]
			}, {
	        	xtype		: 'textarea',
	        	fieldLabel	: '{/literal}{$customtvs.grid_form_element_label_description}{literal}',
	        	description	: MODx.expandHelp ? '' : '{/literal}{$customtvs.grid_form_element_label_description_desc}{literal}',
	        	name		: 'description',
	        	anchor		: '100%',
	        	height		: '30'
	        }, {
	        	xtype		: MODx.expandHelp ? 'label' : 'hidden',
	            html		: '{/literal}{$customtvs.grid_form_element_label_description_desc}{literal}',
	            cls			: 'desc-under'
	        }, {
		    	xtype		: 'fieldset',
		    	title		: '{/literal}{$customtvs.grid_extra_settings}{literal}',
				collapsible : true,
				collapsed 	: true,
				id			: 'customtvs-extra-settings-update',
				defaults	: {
	                layout		: 'form',
	                labelSeparator : ''
	            },
				items		: [{
				    xtype		: 'panel',
				    id 			: 'customtvs-extra-default-update',
				    style 		: 'padding-top: 2px',
				    hidden 		: false,
				    defaults	: {
		                layout		: 'form',
		                labelSeparator : ''
		            },
				    items		: [{
			        	xtype		: 'label',
			            html		: '{/literal}{$customtvs.grid_no_extra_settings}{literal}',
			            cls			: 'desc-under'
			        }]
				}, {
				    xtype		: 'panel',
				    id 			: 'customtvs-extra-datefield-update',
				    style 		: 'padding-top: 15px',
				    hidden 		: true,
				    defaults	: {
		                layout		: 'form',
		                labelSeparator : ''
		            },
				    items		: [{
			            layout		: 'column',
			            border		: false,
			            defaults	: {
			                layout		: 'form',
			                labelSeparator : ''
			            },
			            items: [{
			                columnWidth: .5,
			                items		: [{
					        	xtype		: 'datefield',
					        	fieldLabel	: '{/literal}{$customtvs.grid_form_element_label_mindate}{literal}',
					        	description	: MODx.expandHelp ? '' : '{/literal}{$customtvs.grid_form_element_label_mindate_desc}{literal}',
					        	name		: 'minDateValue',
					        	anchor		: '100%',
					        	format		: MODx.config.manager_date_format,
								startDay	: parseInt(MODx.config.manager_week_start),
								value 		: config.record.extra.minDateValue
					        }, {
					        	xtype		: MODx.expandHelp ? 'label' : 'hidden',
					            html		: '{/literal}{$customtvs.grid_form_element_label_mindate_desc}{literal}',
					            cls			: 'desc-under'
					        }]
					    }, {
					    	columnWidth: .5,
					    	style		: 'margin-right: 0;',
			                items		: [{
					        	xtype		: 'datefield',
					        	fieldLabel	: '{/literal}{$customtvs.grid_form_element_label_maxdate}{literal}',
					        	description	: MODx.expandHelp ? '' : '{/literal}{$customtvs.grid_form_element_label_maxdate_desc}{literal}',
					        	name		: 'maxDateValue',
					        	anchor		: '100%',
					        	format		: MODx.config.manager_date_format,
								startDay	: parseInt(MODx.config.manager_week_start),
								value 		: config.record.extra.maxDateValue
					        }, {
					        	xtype		: MODx.expandHelp ? 'label' : 'hidden',
					            html		: '{/literal}{$customtvs.grid_form_element_label_maxdate_desc}{literal}',
					            cls			: 'desc-under'
					        }]
					    }]
					}]
				}, {
				    xtype		: 'panel',
				    id 			: 'customtvs-extra-timefield-update',
				    style 		: 'padding-top: 15px',
				    hidden 		: true,
				    defaults	: {
		                layout		: 'form',
		                labelSeparator : ''
		            },
				    items		: [{
			            layout		: 'column',
			            border		: false,
			            defaults	: {
			                layout		: 'form',
			                labelSeparator : ''
			            },
			            items: [{
			                columnWidth: .5,
			                items		: [{
					        	xtype		: 'timefield',
					        	fieldLabel	: '{/literal}{$customtvs.grid_form_element_label_mintime}{literal}',
					        	description	: MODx.expandHelp ? '' : '{/literal}{$customtvs.grid_form_element_label_mintime_desc}{literal}',
					        	name		: 'minTimeValue',
					        	anchor		: '100%',
					        	format		: MODx.config.manager_time_format,
					        	value 		: config.record.extra.minTimeValue
					        }, {
					        	xtype		: MODx.expandHelp ? 'label' : 'hidden',
					            html		: '{/literal}{$customtvs.grid_form_element_label_mintime_desc}{literal}',
					            cls			: 'desc-under'
					        }]
					    }, {
					    	columnWidth: .5,
					    	style		: 'margin-right: 0;',
			                items		: [{
					        	xtype		: 'timefield',
					        	fieldLabel	: '{/literal}{$customtvs.grid_form_element_label_maxtime}{literal}',
					        	description	: MODx.expandHelp ? '' : '{/literal}{$customtvs.grid_form_element_label_maxtime_desc}{literal}',
					        	name		: 'maxTimeValue',
					        	anchor		: '100%',
					        	format		: MODx.config.manager_time_format,
					        	value 		: config.record.extra.maxTimeValue
					        }, {
					        	xtype		: MODx.expandHelp ? 'label' : 'hidden',
					            html		: '{/literal}{$customtvs.grid_form_element_label_maxtime_desc}{literal}',
					            cls			: 'desc-under'
					        }]
					    }]
					}]
				}, {
				    xtype		: 'panel',
				    id 			: 'customtvs-extra-richtext-update',
				    style 		: 'padding-top: 15px',
				    hidden 		: true,
				    defaults	: {
		                layout		: 'form',
		                labelSeparator : ''
		            },
				    items		: [{
			            layout		: 'column',
			            border		: false,
			            defaults	: {
			                layout		: 'form',
			                labelSeparator : ''
			            },
			            items: [{
			                columnWidth: .5,
			                items		: [{
					        	xtype		: 'textfield',
					        	fieldLabel	: '{/literal}{$customtvs.grid_form_element_label_toolbar1}{literal}',
					        	description	: MODx.expandHelp ? '' : '{/literal}{$customtvs.grid_form_element_label_toolbar1_desc}{literal}',
					        	name		: 'toolbar1',
					        	anchor		: '100%',
					        	value		: config.record.extra.toolbar1 || 'undo redo | bold italic underline strikethrough | styleselect bullist numlist outdent indent'
					        }, {
					        	xtype		: MODx.expandHelp ? 'label' : 'hidden',
					            html		: '{/literal}{$customtvs.grid_form_element_label_toolbar1_desc}{literal}',
					            cls			: 'desc-under'
					        }, {
					        	xtype		: 'textfield',
					        	fieldLabel	: '{/literal}{$customtvs.grid_form_element_label_toolbar3}{literal}',
					        	description	: MODx.expandHelp ? '' : '{/literal}{$customtvs.grid_form_element_label_toolbar3_desc}{literal}',
					        	name		: 'toolbar3',
					        	anchor		: '100%',
					        	value		: config.record.extra.toolbar3 || ''
					        }, {
					        	xtype		: MODx.expandHelp ? 'label' : 'hidden',
					            html		: '{/literal}{$customtvs.grid_form_element_label_toolbar3_desc}{literal}',
					            cls			: 'desc-under'
					        }]
					    }, {
					    	columnWidth: .5,
					    	style		: 'margin-right: 0;',
			                items		: [{
					        	xtype		: 'textfield',
					        	fieldLabel	: '{/literal}{$customtvs.grid_form_element_label_toolbar2}{literal}',
					        	description	: MODx.expandHelp ? '' : '{/literal}{$customtvs.grid_form_element_label_toolbar2_desc}{literal}',
					        	name		: 'toolbar2',
					        	anchor		: '100%',
					        	value		: config.record.extra.toolbar2 || ''
					        }, {
					        	xtype		: MODx.expandHelp ? 'label' : 'hidden',
					            html		: '{/literal}{$customtvs.grid_form_element_label_toolbar2_desc}{literal}',
					            cls			: 'desc-under'
					        }, {
					        	xtype		: 'textfield',
					        	fieldLabel	: '{/literal}{$customtvs.grid_form_element_label_plugins}{literal}',
					        	description	: MODx.expandHelp ? '' : '{/literal}{$customtvs.grid_form_element_label_plugins_desc}{literal}',
					        	name		: 'plugins',
					        	anchor		: '100%',
					        	value		: config.record.extra.plugins || ''
					        }, {
					        	xtype		: MODx.expandHelp ? 'label' : 'hidden',
					            html		: '{/literal}{$customtvs.grid_form_element_label_plugins_desc}{literal}',
					            cls			: 'desc-under'
					        }]
					    }]
					}]
				}, {
				    xtype		: 'customtvs-combo-values',
				    id 			: 'customtvs-extra-combos-update',
				    style 		: 'padding-top: 15px',
				    hidden 		: true,
				    defaults	: {
		                layout		: 'form',
						labelSeparator : ''
		            },
		            value 		: Ext.encode(config.record.extra.values) || '[]'
				}, {
				    xtype		: 'panel',
				    id 			: 'customtvs-extra-browser-update',
				    style 		: 'padding-top: 15px',
				    hidden 		: true,
				    defaults	: {
		                layout		: 'form',
		                labelSeparator : ''
		            },
				    items		: [{
			            layout		: 'column',
			            border		: false,
			            defaults	: {
			                layout		: 'form',
			                labelSeparator : ''
			            },
			            items: [{
			                columnWidth: .5,
			                items		: [{
					        	xtype		: 'modx-combo-source',
					        	fieldLabel	: '{/literal}{$customtvs.grid_form_element_label_source}{literal}',
					        	description	: MODx.expandHelp ? '' : '{/literal}{$customtvs.grid_form_element_label_source_desc}{literal}',
					        	name		: 'source',
					        	anchor		: '100%',
					        	value 		: config.record.extra.source || MODx.config.default_media_source
					        }, {
					        	xtype		: MODx.expandHelp ? 'label' : 'hidden',
					            html		: '{/literal}{$customtvs.grid_form_element_label_source_desc}{literal}',
					            cls			: 'desc-under'
					        }, {
					        	xtype		: 'textfield',
					        	fieldLabel	: '{/literal}{$customtvs.grid_form_element_label_filetypes}{literal}',
					        	description	: MODx.expandHelp ? '' : '{/literal}{$customtvs.grid_form_element_label_filetypes_desc}{literal}',
					        	name		: 'allowedFileTypes',
					        	anchor		: '100%',
					        	value		: config.record.extra.allowedFileTypes || ''
					        }, {
					        	xtype		: MODx.expandHelp ? 'label' : 'hidden',
					            html		: '{/literal}{$customtvs.grid_form_element_label_filetypes_desc}{literal}',
					            cls			: 'desc-under'
					        }]
					    }, {
					    	columnWidth: .5,
					    	style		: 'margin-right: 0;',
			                items		: [{
					        	xtype		: 'textfield',
					        	fieldLabel	: '{/literal}{$customtvs.grid_form_element_label_opento}{literal}',
					        	description	: MODx.expandHelp ? '' : '{/literal}{$customtvs.grid_form_element_label_opento_desc}{literal}',
					        	name		: 'openTo',
					        	anchor		: '100%',
					        	value 		: config.record.extra.openTo || '/'
					        }, {
					        	xtype		: MODx.expandHelp ? 'label' : 'hidden',
					            html		: '{/literal}{$customtvs.grid_form_element_label_opento_desc}{literal}',
					            cls			: 'desc-under'
					        }]
					    }]
					}]
				}]
		    }]
	    });
	    
	    CustomTVs.window.UpdateFormElement.superclass.constructor.call(this, config);
	};
	
	Ext.extend(CustomTVs.window.UpdateFormElement, MODx.Window, {
		xtype: function(event) {
			var type = 'update';
			
			var elements = {
				default 		: true,
				datefield 		: false,
				timefield 		: false,
				datetimefield	: false,
				richtext		: false,
				combos			: false,
				browser			: false
			};
			
			switch (event.value) {
				case 'datefield':
					elements.default 	= false;
					elements.datefield 	= true;
					
					break;	
				case 'timefield':
					elements.default 	= false;
					elements.timefield 	= true;
					
					break;
				case 'datetimefield':
					elements.default 	= false;
					elements.datefield 	= true;
					elements.timefield 	= true;
					
					break;
				case 'richtext':
					elements.default 	= false;
					elements.richtext 	= true;
					
					break;
				case 'combo':
				case 'radiogroup':
				case 'checkboxgroup':
					elements.default 	= false;
					elements.combos 	= true;
					
					break;
				case 'browser':
					elements.default 	= false;
					elements.browser 	= true;
					
					break;
			}
			
			if (!elements.default) {
				if (undefined !== (cmp = Ext.getCmp('customtvs-extra-settings-' + type))) {
					cmp.expand();
				}
			} else {
				if (undefined !== (cmp = Ext.getCmp('customtvs-extra-settings-' + type))) {
					cmp.collapse();
				}
			}

			for (element in elements) {
				if (undefined !== (elementCmp = Ext.getCmp('customtvs-extra-' + element + '-' + type))) {
					if (elements[element]) {
						elementCmp.show();
					} else {
						elementCmp.hide();
					}
				}
			}
		},
		submit: function(close) {
		    close = close === false ? false : true;
		        
		    var f = this.fp.getForm();
		        
		    if (f.isValid() && this.fireEvent('beforeSubmit', f.getValues())) {
			    var element = {
					xtype 		: f.getValues().xtype,
					name 		: f.getValues().name,
					fieldLabel	: f.getValues().fieldLabel,
					description : f.getValues().description,
					anchor 		: '100%',
					required	: Boolean(f.getValues().required),
					extra 		: {}
				};
			    
			    switch (f.getValues().xtype) {
					case 'datefield':
						element.extra = Ext.applyIf({
							minDateValue	: f.getValues().minDateValue,
							maxDateValue	: f.getValues().maxDateValue,
						}, element.extra);
						
						break;
					case 'timefield':
						element.extra = Ext.applyIf({
							minTimeValue	: f.getValues().minTimeValue,
							maxTimeValue	: f.getValues().maxTimeValue
						}, element.extra);
						
						break;
					case 'datetimefield':
						element.extra = Ext.applyIf({
							minDateValue	: f.getValues().minDateValue,
							maxDateValue	: f.getValues().maxDateValue,
							minTimeValue	: f.getValues().minTimeValue,
							maxTimeValue	: f.getValues().maxTimeValue
						}, element.extra);
						
						break;
					case 'richtext':
						element.extra = Ext.applyIf({
							toolbar1		: f.getValues().toolbar1,
							toolbar2		: f.getValues().toolbar2,
							toolbar3		: f.getValues().toolbar3,
							plugins			: f.getValues().plugins
						}, element.extra);
						
						break;
					case 'combo':
					case 'checkboxgroup':
					case 'radiogroup':
						element.extra = Ext.applyIf({
							values	: Ext.decode(f.getValues().values || '[]')
						}, element.extra);
						
						break;
					case 'browser':
						element.extra = Ext.applyIf({
							source				: f.getValues().source,
							openTo				: f.getValues().openTo,
							allowedFileTypes	: f.getValues().allowedFileTypes
						}, element.extra);
						
						break;
				}

			    this.config.scope.getStore().getAt(f.getValues().idx).data = element;
			    
		        if (this.config.success) {
		            Ext.callback(this.config.success, this.config.scope || this, [f]);
		        }
		
		        if (this.fireEvent('success', f)) {
			    	if (close) {
		        		this.config.closeAction !== 'close' ? this.hide() : this.close();
					}
		       	}
			}
		}
	});
	
	Ext.reg('customtvs-window-formelement-update', CustomTVs.window.UpdateFormElement);
	
	CustomTVs.grid.GridElements = function(config) {
	    config = config || {};
	    
	    this.store = new Ext.data.JsonStore({
	    	fields		: ['idx', 'header', 'dataIndex', 'width', 'fixed', 'sortable', 'editable', 'renderer'],
			data		: Ext.decode(Ext.getCmp('customtvs-{/literal}{$tv}{literal}-gridelements').getValue() || '[]'),
			remoteSort	: true
		});
	
		config.tbar = [{
	        text	: '{/literal}{$customtvs.grid_grid_element_create}{literal}',
	        cls		:'primary-button',
	        handler	: this.createGridElement,
	        scope	: this
	   	}];
	
	    columns = new Ext.grid.ColumnModel({
	        columns: [{
	            header		: '{/literal}{$customtvs.grid_grid_element_label_element}{literal}',
	            dataIndex	: 'dataIndex',
	            sortable	: false,
	            editable	: false,
	            width		: 200,
	            fixed		: true
	        }, {
	            header		: '{/literal}{$customtvs.grid_grid_element_label_header}{literal}',
	            dataIndex	: 'header',
	            sortable	: false,
	            editable	: false,
	            width		: 300,
	            fixed 		: false
	        }, {
	            header		: '{/literal}{$customtvs.grid_grid_element_label_renderer}{literal}',
	            dataIndex	: 'renderer',
	            sortable	: false,
	            editable	: false,
	            width		: 200,
	            fixed		: true,
	            renderer 	: this.renderRenderer
	        }]
	    });
	    
	    Ext.applyIf(config, {
	    	cm			: columns,
	        id			: 'customtvs-grid-gridelements',
	        fields		: ['idx', 'header', 'dataIndex', 'width', 'fixed', 'sortable', 'editable', 'renderer'],
	        paging		: false,
	        store		: this.store,
			autoHeight	: true,
			enableDragDrop : true,
			ddGroup 	: 'customtvs-grid-gridelements', 
	        listeners	: {
		    	'afteredit'	: {
		        	fn			: this.encodeData,
		        	scope		: this
		        },
		        'afterrender' : {
		           fn			: this.ddData,
		           scope		: this
		    	}
			}
	    });
	    
	    CustomTVs.grid.GridElements.superclass.constructor.call(this, config);
	};
	
	Ext.extend(CustomTVs.grid.GridElements, MODx.grid.LocalGrid, {
		refreshData: function(data) {
			this.getStore().loadData(data);
			this.encodeData();	
		},
		getMenu: function() {
		    return [{
			   	text	: '{/literal}{$customtvs.grid_grid_element_update}{literal}',
			    handler	: this.updateGridElement,
			    scope	: this
			}, '-', {
				text	: '{/literal}{$customtvs.grid_grid_element_remove}{literal}',
				handler	: this.removeGridElement,
				scope	: this
			}];
		},
		createGridElement: function(btn, e) {
	        if (this.createGridElementWindow) {
		        this.createGridElementWindow.destroy();
	        }
	        
	        this.createGridElementWindow = MODx.load({
		        xtype		: 'customtvs-window-gridelement-create',
		        closeAction	: 'close',
		        scope		: this,
				listeners	: {
					'success'	: {
				    	fn			: this.encodeData,
						scope		: this
				    }
			    }
	        });
	        
	        this.createGridElementWindow.show(e.target);
	    },
	    updateGridElement: function(btn, e) {
			if (this.updateGridElementWindow) {
				this.updateGridElementWindow.destroy();
			}
			
			this.updateGridElementWindow = MODx.load({
				xtype			: 'customtvs-window-gridelement-update',
				record			: this.menu.record,
				closeAction		:'close',
				scope			: this,
				listeners		: {
					'success'		: {
						fn				: this.encodeData,
						scope			: this
					}
				}
			});
			
			this.updateGridElementWindow.setValues(this.menu.record);
			this.updateGridElementWindow.show(e.target);
		},
		removeGridElement: function(btn, e) {
	    	this.getStore().removeAt(this.menu.record.idx);
	    	this.encodeData();
	    },
	    encodeData: function() {
			var data = [];
	
		    for (i = 0; i <  this.getStore().data.length; i++) {
	 			var output = Ext.applyIf({
		 			idx : i
		 		}, this.getStore().data.items[i].data);

		 		data.push(output);
	        }
	        
	        Ext.getCmp('customtvs-{/literal}{$tv}{literal}-gridelements').setValue(Ext.encode(data)); 
	
	        this.getStore().loadData(data);
	        this.getView().refresh();
		},
		ddData: function() {
		    var grid = this;
	
			var ddrow = new Ext.dd.DropTarget(this.getView().mainBody, {
	        	ddGroup 	: 'customtvs-grid-gridelements',
	            notifyDrop 	: function(dd, e, data) {
	            	var sm = grid.getSelectionModel();
	                var sels = sm.getSelections();
	                var cindex = dd.getDragData(e).rowIndex;
	                
	                if (sm.hasSelection()) {
	                	for (i = 0; i < sels.length; i++) {
	                    	grid.getStore().remove(grid.getStore().getById(sels[i].id));
	                        grid.getStore().insert(cindex, sels[i]);
	                    }
	                    
	                    sm.selectRecords(sels);
	                    
	                    grid.encodeData();
	                }
	            }
	        });
		},
		renderRenderer: function(a, b, c) {
			var renders = {
				''			: '',
	            'image'		: '{/literal}{$customtvs.grid_render_image}{literal}',
				'youtube'	: '{/literal}{$customtvs.grid_render_youtube}{literal}',
				'url'		: '{/literal}{$customtvs.grid_render_url}{literal}',
				'tag'		: '{/literal}{$customtvs.grid_render_tag}{literal}',
				'password'	: '{/literal}{$customtvs.grid_render_password}{literal}',
				'boolean'	: '{/literal}{$customtvs.grid_render_boolean}{literal}',
	            'resource'	: '{/literal}{$customtvs.grid_render_resource}{literal}'
	        };
	        
	        return renders[a];
		}
	});
	
	Ext.reg('customtvs-grid-gridelements', CustomTVs.grid.GridElements);
	
	CustomTVs.window.CreateGridElement = function(config) {
	    config = config || {};
	    
	    Ext.applyIf(config, {
	    	autoHeight	: true,
	        title 		: '{/literal}{$customtvs.grid_grid_element_create}{literal}',
	        defauls		: {
		        labelAlign	: 'top',
	            border		: false
	        },
	        fields		: [{
	        	xtype		: 'customtvs-combo-formelements',
	        	fieldLabel	: '{/literal}{$customtvs.grid_grid_element_label_element}{literal}',
	        	description	: MODx.expandHelp ? '' : '{/literal}{$customtvs.grid_grid_element_label_element_desc}{literal}',
	        	name		: 'dataIndex',
	        	anchor		: '100%',
	        	allowBlank	: false,
	        	listeners 	: {
		        	'select'	: function(event, record) {
			        	var xtype = -1 == ['password', 'boolean', 'resource'].indexOf(record.data.xtype) ? '' : record.data.xtype;

			        	Ext.getCmp('customtvs-grid-header-create').setValue(record.data.fieldLabel);
			        	Ext.getCmp('customtvs-grid-renderer-create').setValue(xtype);
			        }	
		        }
	        }, {
	        	xtype		: MODx.expandHelp ? 'label' : 'hidden',
	            html		: '{/literal}{$customtvs.grid_grid_element_label_element_desc}{literal}',
	            cls			: 'desc-under'
	        }, {
	        	xtype		: 'textfield',
	        	fieldLabel	: '{/literal}{$customtvs.grid_grid_element_label_header}{literal}',
	        	description	: MODx.expandHelp ? '' : '{/literal}{$customtvs.grid_grid_element_label_header_desc}{literal}',
	        	name		: 'header',
	        	id 			: 'customtvs-grid-header-create',
	        	anchor		: '100%',
	        	allowBlank	: false
	        }, {
	        	xtype		: MODx.expandHelp ? 'label' : 'hidden',
	            html		: '{/literal}{$customtvs.grid_grid_element_label_header_desc}{literal}',
	            cls			: 'desc-under'
	        }, {
	        	layout		: 'column',
	        	border		: false,
	        	style		: 'padding-top: 15px',
	            defaults	: {
	                layout		: 'form',
	                labelSeparator : ''
	            },
	        	items		: [{
		        	columnWidth	: .8,
		        	items		: [{
			        	xtype		: 'textfield',
			        	fieldLabel	: '{/literal}{$customtvs.grid_grid_element_label_width}{literal}',
			        	description	: MODx.expandHelp ? '' : '{/literal}{$customtvs.grid_grid_element_label_width_desc}{literal}',
			        	name		: 'width',
			        	anchor		: '100%',
			        	allowBlank	: false
			        }, {
			        	xtype		: MODx.expandHelp ? 'label' : 'hidden',
			            html		: '{/literal}{$customtvs.grid_grid_element_label_width_desc}{literal}',
			            cls			: 'desc-under'
			        }]
		        }, {
			        columnWidth	: .2,
			        style		: 'margin-right: 0;',
			        items		: [{
				        xtype		: 'checkbox',
			            fieldLabel	: '{/literal}{$customtvs.grid_grid_element_label_fixed}{literal}',
			            description	: MODx.expandHelp ? '' : '',
			            name		: 'fixed',
			            inputValue	: true,
			            checked 	: true
			        }]
		        }]	
		    }, {
	        	xtype		: 'customtvs-combo-renderer',
	        	fieldLabel	: '{/literal}{$customtvs.grid_grid_element_label_renderer}{literal}',
	        	description	: MODx.expandHelp ? '' : '{/literal}{$customtvs.grid_grid_element_label_renderer_desc}{literal}',
	        	name		: 'renderer',
	        	id 			: 'customtvs-grid-renderer-create',
	        	anchor		: '100%',
	        	allowBlank	: true
	        }, {
	        	xtype		: MODx.expandHelp ? 'label' : 'hidden',
	            html		: '{/literal}{$customtvs.grid_grid_element_label_renderer_desc}{literal}',
	            cls			: 'desc-under'
	        }]
	    });
	    
	    CustomTVs.window.CreateGridElement.superclass.constructor.call(this, config);
	};
	
	Ext.extend(CustomTVs.window.CreateGridElement, MODx.Window, {
		submit: function(close) {
		    close = close === false ? false : true;
		        
		    var f = this.fp.getForm();
		        
		    if (f.isValid() && this.fireEvent('beforeSubmit', f.getValues())) {
			    var values = f.getValues();

			    this.config.scope.getStore().loadData([Ext.applyIf({
		 			sortable 	: false,
		 			editable	: false
		 		}, values)], true);

		        if (this.config.success) {
		            Ext.callback(this.config.success, this.config.scope || this, [f]);
		        }
		
		        if (this.fireEvent('success', f)) {
			    	if (close) {
		        		this.config.closeAction !== 'close' ? this.hide() : this.close();
					}
		       	}
			}
		}
	});
	
	Ext.reg('customtvs-window-gridelement-create', CustomTVs.window.CreateGridElement);
	
	CustomTVs.window.UpdateGridElement = function(config) {
	    config = config || {};
	    
	    Ext.applyIf(config, {
	    	autoHeight	: true,
	        title 		: '{/literal}{$customtvs.grid_grid_element_update}{literal}',
	        defauls		: {
		        labelAlign	: 'top',
	            border		: false
	        },
	        fields		: [{
		    	'xtype'		: 'hidden',
				'name'		: 'idx'
		    }, {
	        	xtype		: 'customtvs-combo-formelements',
	        	fieldLabel	: '{/literal}{$customtvs.grid_grid_element_label_element}{literal}',
	        	description	: MODx.expandHelp ? '' : '{/literal}{$customtvs.grid_grid_element_label_element_desc}{literal}',
	        	name		: 'dataIndex',
	        	anchor		: '100%',
	        	allowBlank	: false,
	        	listeners 	: {
		        	'select'	: function(event, record) {
			        	var xtype = -1 == ['password', 'boolean', 'resource'].indexOf(record.data.xtype) ? '' : record.data.xtype;

			        	Ext.getCmp('customtvs-grid-header-update').setValue(record.data.fieldLabel);
			        	Ext.getCmp('customtvs-grid-renderer-update').setValue(xtype);
			        }	
		        }
	        }, {
	        	xtype		: MODx.expandHelp ? 'label' : 'hidden',
	            html		: '{/literal}{$customtvs.grid_grid_element_label_element_desc}{literal}',
	            cls			: 'desc-under'
	        }, {
	        	xtype		: 'textfield',
	        	fieldLabel	: '{/literal}{$customtvs.grid_grid_element_label_header}{literal}',
	        	description	: MODx.expandHelp ? '' : '{/literal}{$customtvs.grid_grid_element_label_header_desc}{literal}',
	        	name		: 'header',
	        	id 			: 'customtvs-grid-header-update',
	        	anchor		: '100%',
	        	allowBlank	: false
	        }, {
	        	xtype		: MODx.expandHelp ? 'label' : 'hidden',
	            html		: '{/literal}{$customtvs.grid_grid_element_label_header_desc}{literal}',
	            cls			: 'desc-under'
	        }, {
	        	layout		: 'column',
	        	border		: false,
	        	style		: 'padding-top: 15px',
	            defaults	: {
	                layout		: 'form',
	                labelSeparator : ''
	            },
	        	items		: [{
		        	columnWidth	: .8,
		        	items		: [{
			        	xtype		: 'textfield',
			        	fieldLabel	: '{/literal}{$customtvs.grid_grid_element_label_width}{literal}',
			        	description	: MODx.expandHelp ? '' : '{/literal}{$customtvs.grid_grid_element_label_width_desc}{literal}',
			        	name		: 'width',
			        	anchor		: '100%',
			        	allowBlank	: false
			        }, {
			        	xtype		: MODx.expandHelp ? 'label' : 'hidden',
			            html		: '{/literal}{$customtvs.grid_grid_element_label_width_desc}{literal}',
			            cls			: 'desc-under'
			        }]
		        }, {
			        columnWidth	: .2,
			        style		: 'margin-right: 0;',
			        items		: [{
				        xtype		: 'checkbox',
			            fieldLabel	: '{/literal}{$customtvs.grid_grid_element_label_fixed}{literal}',
			            description	: MODx.expandHelp ? '' : '',
			            name		: 'fixed',
			            inputValue	: true,
			            checked 	: true
			        }]
		        }]	
		    }, {
	        	xtype		: 'customtvs-combo-renderer',
	        	fieldLabel	: '{/literal}{$customtvs.grid_grid_element_label_renderer}{literal}',
	        	description	: MODx.expandHelp ? '' : '{/literal}{$customtvs.grid_grid_element_label_renderer_desc}{literal}',
	        	name		: 'renderer',
	        	id			: 'customtvs-grid-renderer-update',
	        	anchor		: '100%',
	        	allowBlank	: true
	        }, {
	        	xtype		: MODx.expandHelp ? 'label' : 'hidden',
	            html		: '{/literal}{$customtvs.grid_grid_element_label_renderer_desc}{literal}',
	            cls			: 'desc-under'
	        }]
	    });
	    
	    CustomTVs.window.UpdateGridElement.superclass.constructor.call(this, config);
	};

	Ext.extend(CustomTVs.window.UpdateGridElement, MODx.Window, {
		submit: function(close) {
		    close = close === false ? false : true;
		        
		    var f = this.fp.getForm();
		        
		    if (f.isValid() && this.fireEvent('beforeSubmit', f.getValues())) {
			    var values = f.getValues();

			    this.config.scope.getStore().getAt(values.idx).data = Ext.applyIf({
		 			sortable 	: false,
		 			editable	: false
		 		}, values);
			    
		        if (this.config.success) {
		            Ext.callback(this.config.success, this.config.scope || this, [f]);
		        }
		
		        if (this.fireEvent('success', f)) {
			    	if (close) {
		        		this.config.closeAction !== 'close' ? this.hide() : this.close();
					}
		       	}
			}
		}
	});
	
	Ext.reg('customtvs-window-gridelement-update', CustomTVs.window.UpdateGridElement);
	
	CustomTVs.combo.FieldTypes = function(config) {
	    config = config || {};
	    
	    Ext.applyIf(config, {
	        store: new Ext.data.ArrayStore({
	            mode	: 'local',
	            fields	: ['xtype', 'label'],
	            data	: [
	               	['textfield', '{/literal}{$customtvs.textfield}{literal}'],
	               	['datefield', '{/literal}{$customtvs.datefield}{literal}'],
					['timefield', '{/literal}{$customtvs.timefield}{literal}'],
					['datetimefield', '{/literal}{$customtvs.datetimefield}{literal}'], //xdatetime
					['passwordfield', '{/literal}{$customtvs.passwordfield}{literal}'], //text-password
					['numberfield', '{/literal}{$customtvs.numberfield}{literal}'],
	                ['textarea', '{/literal}{$customtvs.textarea}{literal}'],
	                ['richtext', '{/literal}{$customtvs.richtext}{literal}'],
	                ['boolean', '{/literal}{$customtvs.boolean}{literal}'], //combo-boolean
	                ['combo', '{/literal}{$customtvs.combo}{literal}'], //modx-combo
	                ['checkbox', '{/literal}{$customtvs.checkbox}{literal}'],
	                ['checkboxgroup', '{/literal}{$customtvs.checkboxgroup}{literal}'],
	                ['radiogroup', '{/literal}{$customtvs.radiogroup}{literal}'],
	                ['resource', '{/literal}{$customtvs.resource}{literal}'], //modx-field-parent-change
	                ['browser', '{/literal}{$customtvs.browser}{literal}'] //modx-combo-browser
	            ]
	        }),
	        remoteSort	: ['label', 'asc'],
	        hiddenName	: 'xtype',
	        valueField	: 'xtype',
	        displayField: 'label',
	        mode		: 'local',
	        value		: 'textfield'
	    });
	    
	    CustomTVs.combo.FieldTypes.superclass.constructor.call(this,config);
	};
	
	Ext.extend(CustomTVs.combo.FieldTypes, MODx.combo.ComboBox);
	
	Ext.reg('customtvs-combo-xtype', CustomTVs.combo.FieldTypes);
	
	CustomTVs.combo.Values = function(config) {
		config = config || {};

	    Ext.applyIf(config, {
		    xtype		: 'panel',
		    id 			: 'customtvs-extra-combo',
		    hideLabels	: true,
		    items		: [{
	        	xtype		: 'hidden',
	        	anchor		: '100%',
	        	height		: '30',
	        	id 			: (config.id || 'customtvs-extra-combo') + '-value',
	        	name 		: 'values',
	        	value 		: config.value || '[]'
	        }],
	        listeners	: {
	        	'afterrender' : {
					fn 		: this.decodeData,
					scope 	: this
				} 
	        }
		});
		
		CustomTVs.combo.Values.superclass.constructor.call(this, config);
	};
	
	Ext.extend(CustomTVs.combo.Values, MODx.Panel, {
		decodeData: function() {
			var data = Ext.decode(Ext.getCmp(this.config.id + '-value').getValue() || '[]');

			if (null == data || 0 == data.length) {
				this.addElement(0, {});
			} else {
				for (var i = 0; i < data.length; i++) {
					this.addElement(i, data[i]);
				}
			}
		},
		encodeData: function() {
			var data = [];
			var textfields = {
				values : [],
				labels : []	
			};
			
			var elements = this.findByType('textfield');
			
			for (var i = 0; i < elements.length; i++) {
				var element = elements[i];
				
				if ('textfield' == element.xtype) {
					if ('value' == element.type) {
						textfields.values.push(element);
					} else if ('label' == element.type) {
						textfields.labels.push(element);
					}	
				}	
			}
			
			for (var i = 0; i < textfields.values.length; i++) {
				data.push({
					value : textfields.values[i].getValue() || '',
					label : textfields.labels[i].getValue() || ''
				});	
			}
			
			Ext.getCmp(this.config.id + '-value').setValue(Ext.encode(data));
		},
		addElement: function(index, data) {
			this.insert(index, this.getElement(index, data));
			this.doLayout();
			
			this.encodeData();
		},
		removeElement: function(index) {
			this.remove(index);
			this.doLayout();
			
			this.encodeData();
		},
		getElement: function(index, data) {
			var id = new Date().getTime();
			var scope = this;

			var nextBtn = {
			    xtype 		: 'box',
				autoEl 		: {
					tag 		: 'a',
					html		: '<i class="icon icon-plus"></i>',
					style 		: 'padding: 9px; margin: 0 5px; cursor: pointer;',
					cls 		: 'x-btn',
					current 	: this.config.id + '-' + id
				},
				listeners	: {
					'render'	: function(button) {
						button.getEl().on('click', function(event) {
							var index = scope.items.findIndexBy(function(item) {
								return item.id == button.autoEl.current;
							});
							
							scope.addElement(index + 1, {});
		            	});    
		            }
				}
			};
			
			var prevBtn = {
			    xtype 		: 'box',
				autoEl 		: {
					tag 		: 'a',
					html		: '<i class="icon icon-minus"></i>',
					style 		: 'padding: 9px; margin: 0 5px; cursor: pointer;',
					cls 		: 'x-btn',
					current 	: this.config.id + '-' + id
				},
				listeners	: {
					'render'	: function(button) {
						button.getEl().on('click', function(event) {
							var index = scope.items.findIndexBy(function(item) {
								return item.id == button.autoEl.current;
							});
							
							scope.removeElement(index);
		            	});    
		            }
				}
			};

			return {
	            layout		: 'column',
	            border		: false,
	            id 			: this.config.id + '-' + id,
	            style		: 'margin-bottom: 5px;',
	            defaults	: {
	                layout		: 'form',
	                hideLabels	: true
	            },
	            items: [{
		            columnWidth : .41,
	                items		: [{
			        	xtype		: 'textfield',
			        	anchor		: '100%',
			        	emptyText 	: '{/literal}{$customtvs.grid_value}{literal}',
			        	type 		: 'value',
			        	value		: data.value || '',
			        	listeners	: {
				        	'blur'		: {
					        	fn 			: this.encodeData,
					        	scope		: this
					        }	
				        }
			        }]
			    }, {
			    	columnWidth : .41,
	                items		: [{
			        	xtype		: 'textfield',
			        	anchor		: '100%',
			        	emptyText 	: '{/literal}{$customtvs.grid_label}{literal}',
			        	type 		: 'label',
			        	value		: data.label || '',
			        	listeners	: {
				        	'blur'		: {
					        	fn 			: this.encodeData,
					        	scope		: this
					        }	
				        }
			        }]
			    }, {
			    	columnWidth : .18,
			    	style		: 'margin-right: 0;',
	                items		: 0 == index ? [nextBtn] : [nextBtn, prevBtn]
	            }]
			};
		}	
	});
	
	Ext.reg('customtvs-combo-values', CustomTVs.combo.Values);
	
	CustomTVs.combo.FormElements = function(config) {
	    config = config || {};
	    
	    Ext.applyIf(config, {
	        store: new Ext.data.JsonStore({
	            fields	: ['idx', 'xtype', 'name', 'fieldLabel'],
	            data	: Ext.decode(Ext.getCmp('customtvs-{/literal}{$tv}{literal}-formelements').getValue() || '[]')
	        }),
	        remoteSort	: ['idx', 'asc'],
	        hiddenName	: 'dataIndex',
	        valueField	: 'name',
	        displayField: 'fieldLabel',
	        mode		: 'local',
	        tpl			: new Ext.XTemplate('<tpl for=".">' +
	            '<div class="x-combo-list-item">{fieldLabel} <i>({name})</i></div>' +
	        '</tpl>')
	    });
	    
	    CustomTVs.combo.FormElements.superclass.constructor.call(this,config);
	};
	
	Ext.extend(CustomTVs.combo.FormElements, MODx.combo.ComboBox);
	
	Ext.reg('customtvs-combo-formelements', CustomTVs.combo.FormElements);
	
	CustomTVs.combo.GridSortCol = function(config) {
	    config = config || {};
	    
	    Ext.applyIf(config, {
	        store: new Ext.data.JsonStore({
	            fields	: ['idx', 'xtype', 'dataIndex', 'header'],
	            data	: [{
		        	idx 		: '-1',
		        	xtype 		: 'textfield',
		        	dataIndex	: 'idx',
		        	header 		: '{/literal}{$customtvs.idx}{literal}'  
		        }].concat(Ext.decode(Ext.getCmp('customtvs-{/literal}{$tv}{literal}-gridelements').getValue() || '[]'))
	        }),
	        remoteSort	: ['idx', 'asc'],
	        hiddenName	: 'inopt_gridsortcol',
	        valueField	: 'dataIndex',
	        displayField: 'header',
	        mode		: 'local',
	        tpl			: new Ext.XTemplate('<tpl for=".">' +
	            '<div class="x-combo-list-item">{header} <i>({dataIndex})</i></div>' +
	        '</tpl>')
	    });
	    
	    CustomTVs.combo.GridSortCol.superclass.constructor.call(this,config);
	};
	
	Ext.extend(CustomTVs.combo.GridSortCol, MODx.combo.ComboBox);
	
	Ext.reg('customtvs-combo-sortcol', CustomTVs.combo.GridSortCol);
	
	CustomTVs.combo.GridSortColDir = function(config) {
	    config = config || {};

	    Ext.applyIf(config, {
	        store: new Ext.data.ArrayStore({
	            mode	: 'local',
	            fields	: ['dir', 'label'],
	            data	: [
		            ['ASC', '{/literal}{$customtvs.asc}{literal}'],
	               	['DESC', '{/literal}{$customtvs.desc}{literal}']
	            ]
	        }),
	        remoteSort	: ['dir', 'asc'],
	        hiddenName	: 'inopt_gridsortcoldir',
	        valueField	: 'dir',
	        displayField: 'label',
	        mode		: 'local',
	        value		: ''
	    });
	    
	    CustomTVs.combo.GridSortColDir.superclass.constructor.call(this,config);
	};
	
	Ext.extend(CustomTVs.combo.GridSortColDir, MODx.combo.ComboBox);
	
	Ext.reg('customtvs-combo-sortcoldir', CustomTVs.combo.GridSortColDir);
	
	CustomTVs.combo.Renderer = function(config) {
	    config = config || {};

	    Ext.applyIf(config, {
	        store: new Ext.data.ArrayStore({
	            mode	: 'local',
	            fields	: ['renderer', 'label'],
	            data	: [
		            ['', '{/literal}{$customtvs.grid_no_render}{literal}'],
	               	['image', '{/literal}{$customtvs.grid_render_image}{literal}'],
					['youtube', '{/literal}{$customtvs.grid_render_youtube}{literal}'],
					['url', '{/literal}{$customtvs.grid_render_url}{literal}'],
					['tag', '{/literal}{$customtvs.grid_render_tag}{literal}'],
					['password', '{/literal}{$customtvs.grid_render_password}{literal}'],
					['boolean', '{/literal}{$customtvs.grid_render_boolean}{literal}'],
	                ['resource', '{/literal}{$customtvs.grid_render_resource}{literal}']
	            ]
	        }),
	        remoteSort	: ['label', 'asc'],
	        hiddenName	: 'renderer',
	        valueField	: 'renderer',
	        displayField: 'label',
	        mode		: 'local',
	        value		: ''
	    });
	    
	    CustomTVs.combo.Renderer.superclass.constructor.call(this,config);
	};
	
	Ext.extend(CustomTVs.combo.Renderer, MODx.combo.ComboBox);
	
	Ext.reg('customtvs-combo-renderer', CustomTVs.combo.Renderer);
	
	CustomTVs.combo.CreateType = function(config) {
	    config = config || {};

	    Ext.applyIf(config, {
	        store: new Ext.data.ArrayStore({
	            mode	: 'local',
	            fields	: ['type', 'label'],
	            data	: [
		            ['create', '{/literal}{$customtvs.grid_item_create}{literal}'],
	               	['quick_create', '{/literal}{$customtvs.grid_item_create_quick}{literal}']
	            ]
	        }),
	        remoteSort	: ['label', 'asc'],
	        hiddenName	: 'inopt_createtype',
	        valueField	: 'type',
	        displayField: 'label',
	        mode		: 'local',
	        value		: ''
	    });
	    
	    CustomTVs.combo.CreateType.superclass.constructor.call(this,config);
	};
	
	Ext.extend(CustomTVs.combo.CreateType, MODx.combo.ComboBox);
	
	Ext.reg('customtvs-combo-create-type', CustomTVs.combo.CreateType);
	
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
        	xtype			: 'hidden',
        	name			: 'inopt_formelements',
        	hiddenName		: 'inopt_formelements',
        	id				: 'customtvs-{/literal}{$tv}{literal}-formelements',
        	anchor			: '100%',
        	value			: params['formelements'] || '[]',
        	allowBlank		: false,
        	listeners		: listeners
        }, {
			xtype			: 'customtvs-grid-formelements',
			fieldLabel		: '{/literal}{$customtvs.grid_label_form_elements}{literal}',
			preventRender	: true
		}, {
        	xtype			: 'hidden',
        	name			: 'inopt_gridelements',
        	hiddenName		: 'inopt_gridelements',
        	id				: 'customtvs-{/literal}{$tv}{literal}-gridelements',
        	anchor			: '100%',
        	value			: params['gridelements'] || '[]',
        	allowBlank		: false,
        	listeners		: listeners
        }, {
			xtype			: 'customtvs-grid-gridelements',
			fieldLabel		: '{/literal}{$customtvs.grid_label_grid_elements}{literal}',
			preventRender	: true
		}, {
        	layout		: 'column',
        	border		: false,
        	style		: 'padding-top: 15px',
        	anchor		: '60%',
            defaults	: {
                layout		: 'form',
                labelSeparator : '',
                labelAlign: 'top'
            },
        	items		: [{
	        	columnWidth	: .5,
	        	items		: [{
		        	xtype		: 'customtvs-combo-sortcol',
		        	fieldLabel	: '{/literal}{$customtvs.grid_label_sortcol}{literal}',
		        	description	: MODx.expandHelp ? '' : '{/literal}{$customtvs.grid_label_sortcol_desc}{literal}',
		        	name		: 'inopt_gridsortcol',
		        	anchor		: '100%',
		        	allowBlank	: false,
		        	value 		: params['gridsortcol'] || 'idx'
		        }, {
		        	xtype		: MODx.expandHelp ? 'label' : 'hidden',
		            html		: '{/literal}{$customtvs.grid_label_sortcol_desc}{literal}',
		            cls			: 'desc-under'
		        }]
	        }, {
		        columnWidth	: .5,
		        style		: 'margin-right: 0;',
		        items		: [{
		        	xtype		: 'customtvs-combo-sortcoldir',
		        	fieldLabel	: '{/literal}{$customtvs.grid_label_sortcoldir}{literal}',
		        	description	: MODx.expandHelp ? '' : '{/literal}{$customtvs.grid_label_sortcoldir_desc}{literal}',
		        	name		: 'inopt_gridsortcoldir',
		        	anchor		: '100%',
		        	allowBlank	: false,
		        	value 		: params['gridsortcoldir'] || 'ASC'
		        }, {
		        	xtype		: MODx.expandHelp ? 'label' : 'hidden',
		            html		: '{/literal}{$customtvs.grid_label_sortcoldir_desc}{literal}',
		            cls			: 'desc-under'
		        }]
	        }]	
	    }, {
        	xtype			: 'combo-boolean',
        	fieldLabel		: '{/literal}{$customtvs.grid_label_sortable}{literal}',
        	description		: MODx.expandHelp ? '' : '{/literal}{$customtvs.grid_label_sortable_desc}{literal}',
			hiddenName		: 'inopt_gridsortable',
        	anchor			: '60%',
        	allowBlank		: true,
        	value			: 'true' == params['gridsortable'] || 1 == params['gridsortable'] ? 1 : 0,
        	listeners		: listeners
        }, {
        	xtype			: MODx.expandHelp ? 'label' : 'hidden',
            html			: '{/literal}{$customtvs.grid_label_sortable_desc}{literal}',
            cls				: 'desc-under'
        }, {
        	xtype			: 'customtvs-combo-create-type',
        	fieldLabel		: '{/literal}{$customtvs.grid_label_createtype}{literal}',
        	description		: MODx.expandHelp ? '' : '{/literal}{$customtvs.grid_label_createtype_desc}{literal}',
        	name			: 'inopt_createtype',
        	anchor			: '60%',
        	allowBlank		: false,
        	value 			: params['createtype'] || 'create'
        }, {
        	xtype			: MODx.expandHelp ? 'label' : 'hidden',
            html			: '{/literal}{$customtvs.grid_label_createtype_desc}{literal}',
            cls				: 'desc-under'
        }],
        renderTo: 'customtvs-{/literal}{$tv}{literal}-properties-div'
	});
	{/literal}
// ]]>
</script>