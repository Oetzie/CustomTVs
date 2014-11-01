<div id="customtvs-{$tv->id}-panel-div">
	<input type="hidden" id="tv{$tv->id}" name="tv{$tv->id}" value="{$tv->value|escape}" />
</div>

<script type="text/javascript">
// <![CDATA[
	{literal}
	Ext.onReady(function() {
		MODx.load({xtype: 'customtvs-{/literal}{$tv->id}{literal}-panel-tv'});
	});
	
	var CustomTVs{/literal}{$tv->id}{literal} = function(config) {
		config = config || {};
		
		CustomTVs{/literal}{$tv->id}{literal}.superclass.constructor.call(this, config);
	};
	
	Ext.extend(CustomTVs{/literal}{$tv->id}{literal}, Ext.Component, {
		page	: {},
		window	: {},
		grid	: {},
		tree	: {},
		panel	: {},
		combo	: {},
		config	: {}
	});
	
	Ext.reg('customtvs-{/literal}{$tv->id}{literal}', CustomTVs{/literal}{$tv->id}{literal});
	
	CustomTVs{/literal}{$tv->id}{literal} = new CustomTVs{/literal}{$tv->id}{literal}();
	
	CustomTVs{/literal}{$tv->id}{literal}.config = {/literal}{$config}{literal};

	CustomTVs{/literal}{$tv->id}{literal}.panel.PanelTv = function(config) {
		config = config || {};

	    Ext.apply(config, {
			id			: 'customtvs-{/literal}{$tv->id}{literal}-panel-tv',
			renderTo	: 'customtvs-{/literal}{$tv->id}{literal}-panel-div',
			cls			: 'container',
			defaults	: {
				collapsible	: false,
				autoHeight	: true,
				autoWidth	: true,
				border		: false
			},
			items		: [{
				xtype		: 'customtvs-{/literal}{$tv->id}{literal}-grid-tv',
				preventRender	: true
			}]
		});
	
		CustomTVs{/literal}{$tv->id}{literal}.panel.PanelTv.superclass.constructor.call(this, config);
	};
	
	Ext.extend(CustomTVs{/literal}{$tv->id}{literal}.panel.PanelTv, MODx.Panel);
	
	Ext.reg('customtvs-{/literal}{$tv->id}{literal}-panel-tv', CustomTVs{/literal}{$tv->id}{literal}.panel.PanelTv);
	
	CustomTVs{/literal}{$tv->id}{literal}.grid.GridTV = function(config) {
	    config = config || {};
	
		config.tbar = [{
	        text	: _('customtvs.item_create'),
	        cls		:'primary-button',
	        handler	: this.createItem,
	        scope	: this
	    }, {
			text	: _('bulk_actions'),
			menu	: [{
				text	: _('customtvs.remove_selected'),
				handler	: this.removeSelectedItem,
				scope	: this
			}]
		}];
		
		sm = new Ext.grid.CheckboxSelectionModel();
	    
	    columns = new Ext.grid.ColumnModel({
	       columns : [sm].concat(this.getColumns())
	    });

		this.store = new Ext.data.JsonStore({
	    	fields		: this.getColumnFields(),
	    	data		: Ext.util.JSON.decode(Ext.get('tv' + {/literal}{$tv->id}{literal}).dom.value || "[]"),
	    	remoteSort	: true
		});

	    Ext.applyIf(config, {
			sm 			: sm,
	    	cm			: columns,
	        id			: 'customtvs-{/literal}{$tv->id}{literal}-grid-tv',
	        fields		: this.getColumnFields(),
			store		: this.store,
			width		: 650,
	        remoteSort	: true
	    });
	
	    CustomTVs{/literal}{$tv->id}{literal}.grid.GridTV.superclass.constructor.call(this, config);
	};
	
	Ext.extend(CustomTVs{/literal}{$tv->id}{literal}.grid.GridTV, MODx.grid.LocalGrid, {
		getColumns: function() {
			var output = [];
			var columns = CustomTVs{/literal}{$tv->id}{literal}.config.grid_elements;
			
			for (i = 0; i < columns.length; i++) {
				var column = Ext.applyIf({
					sortable	: false,
					editable	: false
				}, columns[i]);
				
				if (column.renderer) {
					column.scope = this;
					
					if ('boolean' == column.renderer) {
						column.renderer = this.renderBoolean;
					} else if ('image' == column.renderer) {
						column.renderer = this.renderImage;
					} else if ('youtube' == column.renderer) {
						column.renderer = this.renderYoutube;
					} else if ('url' == column.renderer) {
						column.renderer = this.renderUrl;
					} else if ('tag' == column.renderer) {
						column.renderer = this.renderTag;
					} else if ('password' == column.renderer) {
						column.renderer = this.renderPassword;
					}
				}
				
				output.push(column);
			}
			
			return output;
		},
		getColumnFields: function() {
			var columns = ['idx'];
			var gridElements = CustomTVs{/literal}{$tv->id}{literal}.config.grid_elements;
			
			for (i = 0; i < gridElements.length; i++) {
				columns.push(gridElements[i].dataIndex);
			}
			
			var formElements = CustomTVs{/literal}{$tv->id}{literal}.config.form_elements;
			
			for (i = 0; i < formElements.length; i++) {
				var formElement = formElements[i];
				
				if (-1 == columns.indexOf(formElement.name)) {
					columns.push(formElement.name);
				}
				
				if ('modx-combo' == formElement.xtype) {
					if (-1 == columns.indexOf(formElement.name + '_replace')) {
						columns.push(formElement.name + '_replace');
					}
				}
			}
			
			return columns;
		},
		getMenu: function() {
	        return [{
		        text	: _('customtvs.item_update'),
		        handler	: this.updateItem,
		        scope	: this
		    }, '-', {
			    text	: _('customtvs.item_remove'),
			    handler	: this.removeItem,
			    scope	: this
			 }];
	    },
	    createItem: function(btn, e) {
	        if (this.createItemWindow) {
		        this.createItemWindow.destroy();
	        }
	        
	        this.createItemWindow = MODx.load({
		        xtype		: 'customtvs-{/literal}{$tv->id}{literal}-window-item-create',
		        closeAction	:'close',
		        scope		: this,
		        listeners	: {
			        'success'	: {
			        	fn			: this.encodeData,
			        	scope		: this
			        }
		         }
	        });
	        
	        this.createItemWindow.show(e.target);
	    },
	    updateItem: function(btn, e) {
			if (this.updateItemWindow) {
		        this.updateItemWindow.destroy();
	        }
	
	        this.updateItemWindow = MODx.load({
		        xtype		: 'customtvs-{/literal}{$tv->id}{literal}-window-item-update',
		        record		: this.menu.record,
		        closeAction	:'close',
		        scope		: this,
		        listeners	: {
			        'success'	: {
			        	fn			: this.encodeData,
			        	scope		: this
			        }
		         }
	        });
	        
	        this.updateItemWindow.setValues(this.menu.record);
	        this.updateItemWindow.show(e.target);
	    },
	    removeSelectedItem: function(btn, e) {
	    	var last;
	    	var sels = this.getSelectionModel().getSelections();
	    	
			for (i = 0; i < sels.length ; i++) {
				var current = sels[i].data['idx'];
				
				if (current > last && last != undefined) {
					current = current - 1;
				}
				
				this.getStore().removeAt(current);
				
				if (current < last || last == undefined) {
					last = current;
				}
			}
			
			this.encodeData();
		},
	    removeItem: function(btn, e) {
	    	this.getStore().removeAt(this.menu.recordIndex);
	    	this.encodeData();
	    },
	    renderBoolean: function(d, c) {
	    	c.css = 1 == parseInt(d) || d ? 'green' : 'red';
	    	
	    	return 1 == parseInt(d) || d ? _('yes') : _('no');
	    },
	    renderImage: function(d, c) {
	    	var regExp = /^(http|https|www)/;
	    	
	    	if (regExp.test(d) || '' != d) {
	    		if (false == regExp.test(d)) {
	    			d = MODx.config.connectors_url + 'system/phpthumb.php?w=110&h=70&zc=1&src=' + d;
	    		}
	    		
	    		return '<img src="' + d + '" style="display: block; width: 110px; height: 70px; margin: 0 auto;" alt="" />' ;
	    	}
	    	
	    	return d;
	    },
	    renderYoutube: function(d, c) {
	    	var regExp = /^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#\&\?]*).*/;
			var match = d.match(regExp);
			
			if (match && 11 == match[7].length || 11 == d.length) {
				if (11 != d.length) {
					d = match[7];
				}
				
				return '<iframe width="110" height="70" src="//www.youtube.com/embed/' + d +'?controls=0&rel=0&showinfo=0" frameborder="0" style="display: block; width: 110px; height: 70px; margin: 0 auto;"></iframe>';
			}
	    	
	    	return this.renderUrl(d, c);
	    },
	    renderUrl: function(d, c) {
	    	if ('' != d) {
        		return '<a href="' + d + '" target="_blank">' + d + '</a>';
        	}
        	
        	return d;
		},
		renderTag: function(d, c) {
			if ('' != d) {
				return '[[+' + d + '+]]';
			}
			
			return d;
		},
		renderPassword: function(d, c) {
        	var value = '';
			
			for (i = 0; i < d.length; i++) {
				value += '*';
			}
			
        	return value;
		},
	    encodeData: function() {
	    	var items = [];
			var data = this.getStore().data;
		    
		    for (i = 0; i <  data.length; i++) {
	 			items.push(Ext.applyIf({idx : i}, data.items[i].json));
	        }

	        if (0 == items.length){
	        	Ext.get('tv' + {/literal}{$tv->id}{literal}).dom.value = ''; 
	        } else {
	        	Ext.get('tv' + {/literal}{$tv->id}{literal}).dom.value = Ext.util.JSON.encode(items); 
	        }
	        
	        this.getStore().loadData(items);
	        this.getView().refresh();
	    }
	});
	
	Ext.reg('customtvs-{/literal}{$tv->id}{literal}-grid-tv', CustomTVs{/literal}{$tv->id}{literal}.grid.GridTV);
	
	CustomTVs{/literal}{$tv->id}{literal}.window.CreateItem = function(config) {
	    config = config || {};
	    
	    Ext.applyIf(config, {
	    	autoHeight	: true,
	        title 		: _('customtvs.item_create'),
	        defauls		: {
		        labelAlign	: 'top',
	            border		: false
	        },
	        fields		: this.getFields()
	    });
	    
	    CustomTVs{/literal}{$tv->id}{literal}.window.CreateItem.superclass.constructor.call(this, config);
	};
	
	Ext.extend(CustomTVs{/literal}{$tv->id}{literal}.window.CreateItem, MODx.Window, {
		getFields: function() {
			var output = [];
			var fields = CustomTVs{/literal}{$tv->id}{literal}.config.form_elements;
			
			for (i = 0; i < fields.length; i++) {
				var field = Ext.applyIf(fields[i], {
					id			: 'customtvs-{/literal}{$tv->id}{literal}-' + fields[i].xtype + '-' + fields[i].name,
					xtype		: 'textfield',
					anchor		: '100%',
					description	: ''
				});
				
				if ('checkbox' == field.xtype) {
					field = Ext.applyIf(field, {
						inputValue	: 1
					});
				} else if ('modx-combo-browser' == field.xtype) {
					field = Ext.applyIf(field, {
						source		: MODx.config.default_media_source,
						listeners	: {
							'select'	: {
								fn			: function(data) {
									this.setValue(data.fullRelativeUrl);
								}
							}
						}
					});
				} else if ('modx-combo' == field.xtype) {
					var data = [];

					var fieldValues = (field.comboValue ? field.comboValue : '').split('||');
					
					for (a = 0; a < fieldValues.length; a++) {
						var fieldValue = fieldValues[a].split('==');

                        data.push([fieldValue[fieldValue[1] ? 1 : 0], fieldValue[0]]);
					}
						
					field = Ext.applyIf(field, {
				   		store			: new Ext.data.ArrayStore({
							fields			: ['value','label'],
							data			: data
						}),
						mode 			: 'local',
						hiddenName		: field.name,
						valueField		: 'value',
						displayField	: 'label',
						listeners		: {
							'select'	: function(data) {
								Ext.getCmp(data.id + '_replace').setValue(data.lastSelectionText);
							}
						}
					});
					
					output.push({
						'xtype'	: 'hidden',
						'name'	: field.name + '_replace',
						'id'	: field.id + '_replace'
					});
				}
				
				output.push(Ext.applyIf({
					description	: MODx.expandHelp ? '' : field.description
				}, field));
				output.push({
		        	xtype		: MODx.expandHelp ? 'label' : 'hidden',
		            html		: field.description,
		            cls			: 'desc-under'
		        });
			}
			
			return output;
		},
		submit: function(close) {
	        close = close === false ? false : true;
	        
	        var f = this.fp.getForm();
	        
	        if (f.isValid() && this.fireEvent('beforeSubmit', f.getValues())) {
	        	this.config.scope.getStore().loadData([f.getValues()], true);
	  
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
	
	Ext.reg('customtvs-{/literal}{$tv->id}{literal}-window-item-create', CustomTVs{/literal}{$tv->id}{literal}.window.CreateItem);
	
	CustomTVs{/literal}{$tv->id}{literal}.window.UpdateItem = function(config) {
	    config = config || {};
	    
	    Ext.applyIf(config, {
	    	autoHeight	: true,
	        title 		: _('customtvs.item_create'),
	        defauls		: {
		        labelAlign	: 'top',
	            border		: false
	        },
	        fields		: [{
	        	'xtype'		: 'hidden',
	        	'name'		: 'idx'
	        }].concat(this.getFields())
	    });
	    
	    CustomTVs{/literal}{$tv->id}{literal}.window.UpdateItem.superclass.constructor.call(this, config);
	};
	
	Ext.extend(CustomTVs{/literal}{$tv->id}{literal}.window.UpdateItem, MODx.Window, {
		getFields: function() {
			var output = [];
			var fields = CustomTVs{/literal}{$tv->id}{literal}.config.form_elements;
			
			for (i = 0; i < fields.length; i++) {
				var field = Ext.applyIf(fields[i], {
					id			: 'customtvs-{/literal}{$tv->id}{literal}-' + fields[i].xtype + '-' + fields[i].name,
					xtype		: 'textfield',
					anchor		: '100%',
					description	: ''
				});
				
				if ('checkbox' == field.xtype) {
					field = Ext.applyIf(field, {
						inputValue	: 1
					});
				} else if ('modx-combo-browser' == field.xtype) {
					field = Ext.applyIf(field, {
						source		: MODx.config.default_media_source,
						listeners	: {
							'select'	: {
								fn			: function(data) {
									this.setValue(data.fullRelativeUrl);
								}
							}
						}
					});
				} else if ('modx-combo' == field.xtype) {
					var data = [];

					var fieldValues = (field.comboValue ? field.comboValue : '').split('||');
					
					for (a = 0; a < fieldValues.length; a++) {
						var fieldValue = fieldValues[a].split('==');

                        data.push([fieldValue[fieldValue[1] ? 1 : 0], fieldValue[0]]);
					}
						
					field = Ext.applyIf(field, {
				   		store			: new Ext.data.ArrayStore({
							fields			: ['value','label'],
							data			: data
						}),
						mode 			: 'local',
						hiddenName		: field.name,
						valueField		: 'value',
						displayField	: 'label',
						listeners		: {
							'select'	: function(data) {
								Ext.getCmp(data.id + '_replace').setValue(data.lastSelectionText);
							}
						}
					});
					
					output.push({
						'xtype'	: 'hidden',
						'name'	: field.name + '_replace',
						'id'	: field.id + '_replace'
					});
				}
				
				output.push(Ext.applyIf({
					description	: MODx.expandHelp ? '' : field.description
				}, field));
				output.push({
		        	xtype		: MODx.expandHelp ? 'label' : 'hidden',
		            html		: field.description,
		            cls			: 'desc-under'
		        });
			}
			
			return output;
		},
		submit: function(close) {
	        close = close === false ? false : true;
	        
	        var f = this.fp.getForm();
	        
	        if (f.isValid() && this.fireEvent('beforeSubmit', f.getValues())) {
	        	this.config.scope.getStore().getAt(f.getValues().idx).json = f.getValues();
	        
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
	
	Ext.reg('customtvs-{/literal}{$tv->id}{literal}-window-item-update', CustomTVs{/literal}{$tv->id}{literal}.window.UpdateItem);
	{/literal}
// ]]>
</script>