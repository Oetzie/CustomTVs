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
	    	data		: Ext.decode(Ext.get('tv' + {/literal}{$tv->id}{literal}).dom.value || "[]"),
	    	remoteSort	: true
		});

	    Ext.applyIf(config, {
			sm 			: sm,
	    	cm			: columns,
	        id			: 'customtvs-{/literal}{$tv->id}{literal}-grid-tv',
	        fields		: this.getColumnFields(),
			store		: this.store,
			width		: 650,
	        remoteSort	: true,
	        enableDragDrop : CustomTVs{/literal}{$tv->id}{literal}.config.grid_sortable,
	        ddGroup 	: 'customtvs-{/literal}{$tv->id}{literal}-grid-tv', 
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
	
	    CustomTVs{/literal}{$tv->id}{literal}.grid.GridTV.superclass.constructor.call(this, config);
	};
	
	Ext.extend(CustomTVs{/literal}{$tv->id}{literal}.grid.GridTV, MODx.grid.LocalGrid, {
		getColumns: function() {
			var columns = [];
			var _columns = CustomTVs{/literal}{$tv->id}{literal}.config.grid_elements;
			
			for (i = 0; i < _columns.length; i++) {
				var column = Ext.applyIf({
					sortable	: false
				}, _columns[i]);
				
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
					} else if ('resource' == column.renderer) {
						column.renderer = this.renderResource;
					}
				}
				
				columns.push(column);
			}
			
			return columns;
		},
		getColumnFields: function() {
			var columns = ['idx'];
			var elements = CustomTVs{/literal}{$tv->id}{literal}.config.grid_elements;
			
			for (i = 0; i < elements.length; i++) {
				columns.push(elements[i].dataIndex);
			}
			
			var elements = CustomTVs{/literal}{$tv->id}{literal}.config.form_elements;
			
			for (i = 0; i < elements.length; i++) {
				var element = elements[i];
				
				if (-1 == columns.indexOf(element.name)) {
					columns.push(element.name);
				}
				
				if (-1 != ['modx-combo', 'modx-combo-browser', 'modx-field-parent-change'].indexOf(element.xtype)) {
					if (-1 == columns.indexOf(element.name + '_replace')) {
						columns.push(element.name + '_replace');
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
	    renderBoolean: function(d, c, e) {
	    	c.css = 1 == parseInt(d) || d ? 'green' : 'red';
	    	
	    	return 1 == parseInt(d) || d ? _('yes') : _('no');
	    },
	    renderImage: function(d, c, e) {
	    	var regExp = /^(http|https|www)/;
	    	
	    	if (regExp.test(d) || '' != d) {
	    		if (false == regExp.test(d)) {
	    			d = MODx.config.connectors_url + 'system/phpthumb.php?w=110&h=70&zc=1&src=' + d;
	    		}
	    		
	    		return '<img src="' + d + '" style="display: block; width: 110px; height: 70px; margin: 0 auto;" alt="" />' ;
	    	}
	    	
	    	return d;
	    },
	    renderYoutube: function(d, c, e) {
	    	var regExp = /^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#\&\?]*).*/;
			var match = d.match(regExp);
			
			if (match && 11 == match[7].length || 11 == d.length) {
				if (11 != d.length) {
					d = match[7];
				}
				
				return '<iframe width="110" height="70" src="//www.youtube.com/embed/' + d +'?controls=0&rel=0&showinfo=0" frameborder="0" style="display: block; width: 110px; height: 70px; margin: 0 auto;"></iframe>';
			}
	    	
	    	return this.renderUrl(d, c, e);
	    },
	    renderUrl: function(d, c, e) {
	    	if ('' != d) {
        		return '<a href="' + d + '" target="_blank">' + d + '</a>';
        	}
        	
        	return d;
		},
		renderTag: function(d, c, e) {
			if ('' != d) {
				return '[[+' + d + '+]]';
			}
			
			return d;
		},
		renderPassword: function(d, c, e) {
        	var value = '';
			
			for (i = 0; i < d.length; i++) {
				value += '*';
			}
			
        	return value;
		},
		renderResource: function(d, c, e) {
			var key = Object.keys(e.data).filter(function(key) {return e.data[key] === d})[0];
			
			if (undefined != key) {
				return '<a href="?a=resource/update&id=' + d + '" target="_blank">' + e.data[key + '_replace'] + '</a>';
			}

        	return d;
		},
	    encodeData: function() {
	    	var data = [];

		    for (i = 0; i <  this.getStore().data.length; i++) {
	 			data.push(Ext.applyIf({idx : i}, this.getStore().data.items[i].data));
	        }
	        
	        //if (0 == items.length){
	        //	Ext.get('tv' + {/literal}{$tv->id}{literal}).dom.value = ''; 
	        //} else {
	        	Ext.get('tv' + {/literal}{$tv->id}{literal}).dom.value = Ext.encode(data); 
	        //}

	        this.getStore().loadData(data);
	        this.getView().refresh();
	    },
	    ddData: function() {
		    var grid = this;
		    
			var ddrow = new Ext.dd.DropTarget(this.getView().mainBody, {
	        	ddGroup 	: 'customtvs-{/literal}{$tv->id}{literal}-grid-tv',
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
		}
	});
	
	Ext.reg('customtvs-{/literal}{$tv->id}{literal}-grid-tv', CustomTVs{/literal}{$tv->id}{literal}.grid.GridTV);
	
	CustomTVs{/literal}{$tv->id}{literal}.window.CreateItem = function(config) {
	    config = config || {};
	    
	    Ext.applyIf(config, {
	    	autoHeight	: true,
	    	id			: 'customtvs-{/literal}{$tv->id}{literal}-create-form-panel',
	        title 		: _('customtvs.item_create'),
	        defauls		: {
		        labelAlign	: 'top',
	            border		: false
	        },
	        fields		: this.getElements()
	    });
	    
	    CustomTVs{/literal}{$tv->id}{literal}.window.CreateItem.superclass.constructor.call(this, config);
	};
	
	Ext.extend(CustomTVs{/literal}{$tv->id}{literal}.window.CreateItem, MODx.Window, {
		getElements: function() {
			var elements = [];
			var _elements = CustomTVs{/literal}{$tv->id}{literal}.config.form_elements;

			for (i = 0; i < _elements.length; i++) {
				var element = Ext.applyIf({}, _elements[i]);
				
				element = Ext.applyIf(element, {
					id			: 'customtvs-{/literal}{$tv->id}{literal}-' + _elements[i].xtype + '-' + _elements[i].name,
					xtype		: 'textfield',
					anchor		: '100%',
					description	: MODx.expandHelp ? '' : element.description
				});

				if ('checkbox' == element.xtype) {
					element = Ext.applyIf({
						inputValue	: 1
					}, element);
				} else if ('modx-combo-browser' == element.xtype) {
					elements.push({
						name		: element.name,
						xtype		: 'hidden',
						id			: element.id + '_replace',
					});
					
					element = Ext.applyIf({
						name		: element.name + '_replace',
						source		: MODx.config.default_media_source,
						listeners	: {
							'select'	: {
								fn			: function(data) {
									Ext.getCmp(this.config.id + '_replace').setValue(data.fullRelativeUrl);
								}
							}
						}
					}, element);
				} else if ('modx-combo' == element.xtype) {
					var data = [];

					var values = (element.comboValue ? element.comboValue : '').split('||');
					
					for (a = 0; a < values.length; a++) {
						var value = values[a].split('==');

                        data.push([value[value[1] ? 1 : 0], value[0]]);
					}
						
					element = Ext.applyIf({
				   		store			: new Ext.data.ArrayStore({
							fields			: ['value','label'],
							data			: data
						}),
						mode 			: 'local',
						hiddenName		: element.name,
						valueField		: 'value',
						displayField	: 'label',
						listeners		: {
							'select'	: function(data) {
								Ext.getCmp(data.id + '_replace').setValue(data.lastSelectionText);
							}
						}
					}, element);
					
					elements.push({
						xtype	: 'hidden',
						name	: element.name + '_replace',
						id		: element.id + '_replace'
					});
				} else if ('modx-field-parent-change' == element.xtype) {
					elements.push({
						xtype	: 'hidden',
						name	: element.name,
						id		: element.id + '_replace'
					});
					
					element = Ext.applyIf({
						name		: element.name + '_replace',
						formpanel	: 'customtvs-{/literal}{$tv->id}{literal}-create-form-panel',
						parentcmp	: element.id + '_replace',
						contextcmp	: null,
						currentid	: 0,
					}, element);
				} else if ('datefield' == element.xtype) {
					element = Ext.applyIf({
						format		: MODx.config.manager_date_format,
						startDay	: parseInt(MODx.config.manager_week_start),
					}, element);
				} else if ('timefield' == element.xtype) {	
					element = Ext.applyIf({
						format		: MODx.config.manager_time_format,
						offset_time	: MODx.config.server_offset_time
					}, element);
				} else if ('xdatetime' == element.xtype) {	
					element = Ext.applyIf({
						dateFormat	: MODx.config.manager_date_format,
						timeFormat	: MODx.config.manager_time_format,
						startDay	: parseInt(MODx.config.manager_week_start),
						offset_time	: MODx.config.server_offset_time
					}, element);
				}

				elements.push(element, {
		        	xtype		: MODx.expandHelp ? 'label' : 'hidden',
		            html		: element.description,
		            cls			: 'desc-under'
		        });
			}

			return elements;
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
	    	id			: 'customtvs-{/literal}{$tv->id}{literal}-update-form-panel',
	        title 		: _('customtvs.item_update'),
	        defauls		: {
		        labelAlign	: 'top',
	            border		: false
	        },
	        fields		: [{
	        	'xtype'		: 'hidden',
	        	'name'		: 'idx'
	        }].concat(this.getElements())
	    });
	    
	    CustomTVs{/literal}{$tv->id}{literal}.window.UpdateItem.superclass.constructor.call(this, config);
	};
	
	Ext.extend(CustomTVs{/literal}{$tv->id}{literal}.window.UpdateItem, MODx.Window, {
		getElements: function() {
			var elements = [];
			var _elements = CustomTVs{/literal}{$tv->id}{literal}.config.form_elements;
			
			for (i = 0; i < _elements.length; i++) {
				var element = Ext.applyIf({}, _elements[i]);
				
				element = Ext.applyIf(element, {
					id			: 'customtvs-{/literal}{$tv->id}{literal}-' + _elements[i].xtype + '-' + _elements[i].name,
					xtype		: 'textfield',
					anchor		: '100%',
					description	: MODx.expandHelp ? '' : element.description
				});
				
				if ('checkbox' == element.xtype) {
					element = Ext.applyIf({
						inputValue	: 1
					}, element);
				} else if ('modx-combo-browser' == element.xtype) {
					elements.push({
						name		: element.name,
						xtype		: 'hidden',
						id			: element.id + '_replace',
					});
					
					element = Ext.applyIf({
						name		: element.name + '_replace',
						source		: MODx.config.default_media_source,
						listeners	: {
							'select'	: {
								fn			: function(data) {
									Ext.getCmp(this.config.id + '_replace').setValue(data.fullRelativeUrl);
								}
							}
						}
					}, element);
				} else if ('modx-combo' == element.xtype) {
					var data = [];

					var values = (element.comboValue ? element.comboValue : '').split('||');
					
					for (a = 0; a < values.length; a++) {
						var value = values[a].split('==');

                        data.push([value[value[1] ? 1 : 0], value[0]]);
					}
						
					element = Ext.applyIf({
				   		store			: new Ext.data.ArrayStore({
							fields			: ['value','label'],
							data			: data
						}),
						mode 			: 'local',
						hiddenName		: element.name,
						valueField		: 'value',
						displayField	: 'label',
						listeners		: {
							'select'	: function(data) {
								Ext.getCmp(data.id + '_replace').setValue(data.lastSelectionText);
							}
						}
					}, element);
					
					elements.push({
						xtype	: 'hidden',
						name	: element.name + '_replace',
						id		: element.id + '_replace'
					});
				} else if ('modx-field-parent-change' == element.xtype) {
					elements.push({
						xtype	: 'hidden',
						name	: element.name,
						id		: element.id + '_replace'
					});
					
					element = Ext.applyIf({
						name		: element.name + '_replace',
						formpanel	: 'customtvs-{/literal}{$tv->id}{literal}-update-form-panel',
						parentcmp	: element.id + '_replace',
						contextcmp	: null,
						currentid	: 0,
					}, element);
				} else if ('datefield' == element.xtype) {
					element = Ext.applyIf({
						format		: MODx.config.manager_date_format,
						startDay	: parseInt(MODx.config.manager_week_start),
					}, element);
				} else if ('timefield' == element.xtype) {	
					element = Ext.applyIf({
						format		: MODx.config.manager_time_format,
						offset_time	: MODx.config.server_offset_time
					}, element);
				} else if ('xdatetime' == element.xtype) {	
					element = Ext.applyIf({
						dateFormat	: MODx.config.manager_date_format,
						timeFormat	: MODx.config.manager_time_format,
						startDay	: parseInt(MODx.config.manager_week_start),
						offset_time	: MODx.config.server_offset_time
					}, element);
				}

				elements.push(element, {
		        	xtype		: MODx.expandHelp ? 'label' : 'hidden',
		            html		: element.description,
		            cls			: 'desc-under'
		        });
			}
			
			return elements;
		},
		submit: function(close) {
	        close = close === false ? false : true;
	        
	        var f = this.fp.getForm();
	        
	        if (f.isValid() && this.fireEvent('beforeSubmit', f.getValues())) {
	        	this.config.scope.getStore().getAt(f.getValues().idx).data = f.getValues();
	        
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