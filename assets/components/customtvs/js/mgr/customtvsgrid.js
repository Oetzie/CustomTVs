CustomTVs.panel.PanelGrid = function(config) {
	config = config || {};
	
	Ext.apply(config, {
		defaults	: {
			width 		: 650,
			autoWidth	: true,
			autoHeight	: true
		},	
		items		: [{
			xtype			: 'customtvs-grid-tv',
			tvid			: config.tvid,
			gridElements	: config.gridElements,
			formElements	: config.formElements,
			gridSortCol		: config.gridSortCol,
			gridSortColDir	: config.gridSortColDir,
			gridSortable	: config.gridSortable,
			gridCreateType	: config.gridCreateType,
			preventRender	: false
		}]
	});
	
	CustomTVs.panel.PanelGrid.superclass.constructor.call(this, config);
};
	
Ext.extend(CustomTVs.panel.PanelGrid, Ext.Panel);

Ext.reg('customtvs-grid-panel-tv', CustomTVs.panel.PanelGrid);

CustomTVs.grid.GridTV = function(config) {
	config = config || {};

	config.tbar = [{
	    text	: _('customtvs.grid_item_create'),
	    cls		:'primary-button',
	    handler	: 'quick_create' == config.gridCreateType ? this.quickCreateItem : this.createItem,
	    scope	: this
	}, {
		text	: _('bulk_actions'),
		menu	: [{
			text	: _('customtvs.grid_item_remove_selected'),
			handler	: this.removeSelectedItem,
			scope	: this
		}]
	}];
	
	sm = new Ext.grid.CheckboxSelectionModel();
	    
	columns = new Ext.grid.ColumnModel({
		columns : [sm].concat(this.getColumns(config.gridElements, config.formElements))
	});

	this.store = new Ext.data.JsonStore({
	    fields		: this.getColumnFields(config.gridElements, config.formElements),
	    data		: Ext.decode(Ext.get('tv' + config.tvid).getValue() || '[]'),
	    remoteSort	: false,
	    sortInfo	: {
            field		: config.gridSortCol || 'idx',
            direction	: config.gridSortColDir || 'ASC'
        }
	});
	
	Ext.applyIf(config, {
	 	sm 			: sm,
	    cm			: columns,
	    id			: 'customtvs-' + config.tvid + '-grid-tv',
	    fields		: this.getColumnFields(config.gridElements, config.formElements),
		store		: this.store,
		stateful	: false,
	    enableDragDrop : config.gridSortable,
	    ddGroup 	: 'customtvs-' + config.tvid + '-grid-tv', 
	    listeners	: {
	    	'afteredit'	: {
	        	fn			: this.encodeData,
	        	scope		: this
	        },
	        'afterrender' : {
	           fn			: this.moveItem,
	           scope		: this
	    	}
		}
	});
		
	CustomTVs.grid.GridTV.superclass.constructor.call(this, config);
};
	
Ext.extend(CustomTVs.grid.GridTV, MODx.grid.LocalGrid, {
	getColumns: function(gridElements, formElements) {
		var columns = [{
			dataIndex 	: 'idx',
			header 		: _('customtvs.grid_idx'), 
			sortable	: false,
			editable	: false,
			fixed 		: true,
			width		: '20px',
			hidden 		: true
		}];
	
		var editors = ['textfield', 'passwordfield', 'numberfield', 'textarea', 'boolean'];
		
		for (var i = 0; i < gridElements.length; i++) {
			var column = Ext.applyIf({
				sortable	: false,
				editable	: false,
				fixed 		: Boolean(gridElements[i].fixed),
				width		: parseInt(gridElements[i].width)
			}, gridElements[i]);
			
			var element = this.getColumnField(column.dataIndex, formElements);
			
			if (element) {
				if (-1 != editors.indexOf(element.xtype)) {
					column = Ext.applyIf({
						editable		: true,
						editor			: {
							xtype			: element.xtype
						}
					}, column);
					
					switch (element.xtype) {
						case 'passwordfield':
							column = Ext.applyIf({
								editor			: {
									xtype 			: 'textfield',
									inputType		: 'password'
								}
							}, column);
							
							break;
						case 'textarea':
							column = Ext.applyIf({
								editor		: {
									xtype 			: 'textfield'
								}
							}, column);
							
							break;
						case 'boolean':
							column = Ext.applyIf({
								editor		: {
									xtype 			: 'combo-boolean'
								}
							}, column);
							
							break;
					}
				}
				
				switch (element.xtype) {
					case 'passwordfield':
						column = Ext.applyIf({
							renderer	: 'password'
						}, column);
							
						break;
					case 'boolean':
						column = Ext.applyIf({
							renderer	: 'boolean'
						}, column);
							
						break;
					case 'resource':
						column = Ext.applyIf({
							renderer	: 'resource'
						}, column);
							
						break;
				}
			}
			
			if (column.renderer) {
				switch (column.renderer) {
					case 'image':
						column = Ext.applyIf({
							renderer	: this.renderImage
						}, column);
						
						break;
					case 'youtube':
						column = Ext.applyIf({
							renderer	: this.renderYoutube
						}, column);

						break;
					case 'url':
						column = Ext.applyIf({
							renderer	: this.renderUrl
						}, column);

						break;
					case 'tag':
						column = Ext.applyIf({
							renderer	: this.renderTag
						}, column);

						break;
					case 'password':
						column = Ext.applyIf({
							renderer	: this.renderPassword
						}, column);

						break;
					case 'boolean':
						column = Ext.applyIf({
							renderer	: this.renderBoolean
						}, column);
						
						break;
					case 'resource':
						column = Ext.applyIf({
							renderer	: this.renderResource
						}, column);

						break;
				}
			}
				
			columns.push(column);
		}
		
		return columns;
	},
	getColumnField: function(dataIndex, formElements) {
		for (var i = 0; i < formElements.length; i++) {
			if (dataIndex == formElements[i].name) {
				return formElements[i];
			}
		}
		
		return false;
	},
	getColumnFields: function(gridElements, formElements) {
		var columns = [{name : 'idx', type: 'string'}];

		for (var i = 0; i < gridElements.length; i++) {
			columns.push({name: gridElements[i].dataIndex, type: 'string'});
		}

		for (var i = 0; i < formElements.length; i++) {
			var column = formElements[i];
			
			if (-1 == columns.indexOf(column.name)) {
				columns.push({name : column.name, type: 'string'});
			}
				
			if (-1 != ['combo', 'browser', 'resource'].indexOf(column.xtype)) {
				if (-1 == columns.indexOf(column.name + '-replace')) {
					columns.push({name : column.name + '-replace', type: 'string'});
				}
			}
		}
			
		return columns;
	},
	getMenu: function() {		
	    return [{
		   	text	: _('customtvs.grid_item_update'),
		    handler	: this.updateItem,
		    scope	: this
		}, {
		   	text	: _('customtvs.grid_item_copy'),
		    handler	: this.copyItem,
		    scope	: this
		}, '-', {
			text	: _('customtvs.grid_item_remove'),
			handler	: this.removeItem,
			scope	: this
		}, '-', {
			text	:  _('customtvs.grid_item_move_top'),
			index	: 'top',
			handler	: this.moveItemTo,
			scope	: this
		}, {
			text	: _('customtvs.grid_item_move_bottom'),
			index	: 'bottom',
			handler	: this.moveItemTo,
			scope	: this
		}];
	},
	createItem: function(btn, e) {
	    if (this.createItemWindow) {
			this.createItemWindow.destroy();
	    }

	    this.createItemWindow = MODx.load({
			xtype			: 'customtvs-window-item-create',
			tvid			: this.tvid,
			gridElements	: this.gridElements,
			formElements	: this.formElements,
			closeAction		:'close',
			scope			: this,
			listeners		: {
				'success'		: {
			    	fn				: this.encodeData,
					scope			: this
			    }
		    }
	    });
	       
	    this.createItemWindow.show(e.target);
	},
	quickCreateItem : function(btn, e) {
		var placeholders = ['name', 'title', 'content', 'description'];
		
		var record = {};
		var fields = this.getColumnFields(this.config.gridElements, this.config.formElements);
		
		for (var i = 0; i < fields.length; i++) {
			if (-1 != placeholders.indexOf(fields[i].name)) {
				record[fields[i].name] = _('customtvs.grid_item_create');
			} else {
				record[fields[i].name] = '';
			}
		}
		
		this.getStore().loadData([record], true);
		this.encodeData();
	},
	copyItem: function(btn, e) {
		if (this.menu.record.name) {
			var element = Ext.applyIf({
				name		: _('customtvs.grid_copy') + ' ' + this.menu.record.name
			}, this.menu.record);
		} else if (this.menu.record.title) {
			var element = Ext.applyIf({
				title		: _('customtvs.grid_copy') + ' ' + this.menu.record.title
			}, this.menu.record);
		} else if (this.menu.record.content) {
			var element = Ext.applyIf({
				content		: _('customtvs.grid_copy') + ' ' + this.menu.record.content
			}, this.menu.record);
		} else if (this.menu.record.description) {
			var element = Ext.applyIf({
				description	: _('customtvs.grid_copy') + ' ' + this.menu.record.description
			}, this.menu.record);
		} else {
			var element = this.menu.record;
		}
			
		this.getStore().loadData([element], true);
		this.encodeData();
	},
	updateItem: function(btn, e) {
		if (this.updateItemWindow) {
			this.updateItemWindow.destroy();
		}
		
		this.updateItemWindow = MODx.load({
			xtype			: 'customtvs-window-item-update',
			tvid			: this.tvid,
			gridElements	: this.gridElements,
			formElements	: this.formElements,
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
		
		this.updateItemWindow.setValues(this.menu.record);
		this.updateItemWindow.show(e.target);
	},
    removeSelectedItem: function(btn, e) {
	    Ext.MessageBox.confirm(_('customtvs.grid_item_remove_selected'), _('customtvs.grid_item_remove_selected_desc'), function(event) {
			if ('yes' == event) {
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
				
				this.getSelectionModel().clearSelections(true);
				
				this.encodeData();
			}
		}, this);
	},
    removeItem: function(btn, e) {
    	this.getStore().removeAt(this.menu.recordIndex);
    	this.encodeData();
    },
    moveItem: function() {
	    var grid = this;
	    
		var ddrow = new Ext.dd.DropTarget(this.getView().mainBody, {
        	ddGroup 	: grid.config.ddGroup,
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
    moveItemTo: function(btn, e) {
	    var record = this.getStore().getAt(this.menu.recordIndex);
	    
	    if ('top' == btn.options.index) {
		    this.getStore().remove(record);
		    
		    this.getStore().insert(0, record);
	    } else if ('bottom' == btn.options.index) {
		    this.getStore().remove(record);
		    
		    this.getStore().add(record);
	    }

    	this.encodeData();
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
	renderBoolean: function(d, c, e) {
    	c.css = 1 == parseInt(d) || d ? 'green' : 'red';
    	
    	return 1 == parseInt(d) || d ? _('yes') : _('no');
    },
	renderResource: function(d, c, e) {
		var key = Object.keys(e.data).filter(function(key) {return e.data[key] === d})[0];
		
		if (undefined != key) {
			return '<a href="?a=resource/update&id=' + d + '" target="_blank">' + e.data[key + '-replace'] + '</a>';
		}

    	return d;
	},
    encodeData: function() {
    	var data = [];

	    for (i = 0; i <  this.getStore().data.length; i++) {
 			data.push(Ext.applyIf({idx : i}, this.getStore().data.items[i].data));
        }
        
        Ext.get('tv' + this.tvid).dom.value = Ext.encode(data); 

        this.getStore().loadData(data);
        this.getView().refresh();
    }
});
	
Ext.reg('customtvs-grid-tv', CustomTVs.grid.GridTV);

CustomTVs.window.GridTVCreateItem = function(config) {
	config = config || {};

	Ext.applyIf(config, {
	    autoHeight	: true,
	    id			: 'customtvs-' + config.tvid + '-create-form-panel',
	    title 		: _('customtvs.grid_item_create'),
	    defauls		: {
		    labelAlign	: 'top',
	        border		: false
	    },
	    fields		: this.getElements(config.formElements, config)
	});
	    
	CustomTVs.window.GridTVCreateItem.superclass.constructor.call(this, config);
};
	
Ext.extend(CustomTVs.window.GridTVCreateItem, MODx.Window, {
	getElements: function(formElements, config) {
		var elements = [];

		for (i = 0; i < formElements.length; i++) {
			formElements[i].id = 'customtvs-' + config.tvid + '-create-' + formElements[i].xtype + '-' + formElements[i].name + '-' + Ext.id();
			
			var element = Ext.applyIf(formElements[i], {
				xtype		: 'textfield',
				anchor		: '100%',
				description	: MODx.expandHelp ? '' : element.description
			});
			
			switch (element.xtype) {
				case 'datefield':
					element = Ext.applyIf({
						format			: MODx.config.manager_date_format,
						startDay		: parseInt(MODx.config.manager_week_start),
						minValue 		: element.extra.minDateValue,
						maxValue 		: element.extra.maxDateValue
					}, element);
					
					break;
				case 'timefield':
					element = Ext.applyIf({
						format			: MODx.config.manager_time_format,
						offset_time		: MODx.config.server_offset_time,
						minValue 		: element.extra.minTimeValue,
						maxValue 		: element.extra.maxTimeValue
					}, element);
					
					break;
				case 'datetimefield':
					element = Ext.applyIf({
						xtype 			: 'xdatetime',
						dateFormat		: MODx.config.manager_date_format,
						timeFormat		: MODx.config.manager_time_format,
						startDay		: parseInt(MODx.config.manager_week_start),
						offset_time		: MODx.config.server_offset_time,
						minDateValue 	: element.extra.minDateValue,
						maxDateValue 	: element.extra.maxDateValue,
						minTimeValue 	: element.extra.minTimeValue,
						maxTimeValue 	: element.extra.maxTimeValue
					}, element);
					
					break;
				case 'passwordfield':
					element = Ext.applyIf({
						xtype 			: 'textfield',
						inputType		: 'password'
					}, element);
					
					break;
				case 'richtext':
					element = Ext.applyIf({
						xtype			: 'textarea',
						listeners		: {
							'afterrender' : {
								fn 			: function() {
									if (MODx.loadRTE) {
										MODx.loadRTE(this.id, {
											toolbar1 				: this.extra.toolbar1 || 'undo redo | bold italic underline strikethrough | styleselect bullist numlist outdent indent',
											toolbar2 				: this.extra.toolbar2 || '',
											toolbar3 				: this.extra.toolbar3 || '',
											plugins 				: this.extra.plugins || '',
											menubar 				: false,
											statusbar				: false,
											height					: '150px',
											toggle					: false
										});
									}
								},
								scope 		: element
							}
						}
					}, element);	
					
					break;
				case 'boolean':
					element = Ext.applyIf({
						xtype			: 'combo-boolean'
					}, element);
					
					break;
				case 'combo':
					elements.push({
						xtype	: 'hidden',
						name	: element.name + '-replace',
						id		: element.id + '-replace'
					});
					
					element = Ext.applyIf({
						xtype			: 'modx-combo',
					   	store			: new Ext.data.JsonStore({
							fields			: ['value', 'label'],
							data			: element.extra.values || []
						}),
						mode 			: 'local',
						hiddenName		: element.name,
						valueField		: 'value',
						displayField	: 'label',
						listeners		: {
							'select'	: function(data) {
								Ext.getCmp(this.config.id + '-replace').setValue(data.lastSelectionText);
							}
						}
					}, element);
				
					break;
				case 'checkbox':
					element = Ext.applyIf({
						fieldLabel 	: '',
						boxLabel	: element.fieldLabel,
						inputValue	: 1
					}, element);
				
					break;
				case 'checkboxgroup':
					var items = [];
	
					for (var ii = 0; ii < element.extra.values.length; ii++) {
						items.push({
							name 		: element.name,
							boxLabel	: element.extra.values[ii].label,
							inputValue	: element.extra.values[ii].value
						});
					}
					
					if (0 < items.length) {
						element = Ext.applyIf({
							xtype			: 'checkboxgroup',
						   	columns			: 1,
						   	items			: items
						}, element);
					}
				
					break;
				case 'radiogroup':
					var items = [];
	
					for (var ii = 0; ii < element.extra.values.length; ii++) {
						items.push({
							name 		: element.name,
							boxLabel	: element.extra.values[ii].label,
							inputValue	: element.extra.values[ii].value
						});
					}
					
					if (0 < items.length) {
						element = Ext.applyIf({
							xtype			: 'radiogroup',
						   	columns			: 1,
						   	items			: items
						}, element);
					}
					
					break;
				case 'resource':
					elements.push({
						xtype	: 'hidden',
						name	: element.name,
						id		: element.id + '-replace'
					});
						
					element = Ext.applyIf({
						xtype		: 'modx-field-parent-change',
						name		: element.name + '-replace',
						formpanel	: 'customtvs-' + config.tvid + '-create-form-panel',
						parentcmp	: element.id + '-replace',
						contextcmp	: null,
						currentid	: 0,
					}, element);
				
					break;
				case 'browser':
					elements.push({
						xtype	: 'hidden',
						name	: element.name,
						id		: element.id + '-replace'
					});
						
					element = Ext.applyIf({
						xtype		: 'modx-combo-browser',
						name		: element.name + '-replace',
						source		: element.extra.source || MODx.config.default_media_source,
						openTo		: element.extra.openTo || '/',
						allowedFileTypes : element.extra.allowedFileTypes || '',
						listeners	: {
							'select'	: {
								fn			: function(data) {
									Ext.getCmp(this.config.id + '-replace').setValue(data.fullRelativeUrl);
								}
							}
						}
					}, element);
				
					break;
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
	
Ext.reg('customtvs-window-item-create', CustomTVs.window.GridTVCreateItem);
	
CustomTVs.window.GridTVUpdateItem = function(config) {
	config = config || {};
	
	Ext.applyIf(config, {
		autoHeight	: true,
		id			: 'customtvs-' + config.tvId + '-update-form-panel',
	    title 		: _('customtvs.grid_item_update'),
	    defauls		: {
			labelAlign	: 'top',
			border		: false
	    },
	    fields		: [{
	    	'xtype'		: 'hidden',
			'name'		: 'idx'
	    }].concat(this.getElements(config.formElements, config))
	});
	    
	CustomTVs.window.GridTVUpdateItem.superclass.constructor.call(this, config);
};
	
Ext.extend(CustomTVs.window.GridTVUpdateItem, MODx.Window, {
	getElements: function(formElements, config) {
		var elements = [];
		
		for (i = 0; i < formElements.length; i++) {
			formElements[i].id = 'customtvs-' + config.tvid + '-update-' + formElements[i].xtype + '-' + formElements[i].name + '-' + Ext.id();
			
			var element = Ext.applyIf(formElements[i], {
				xtype		: 'textfield',
				anchor		: '100%',
				description	: MODx.expandHelp ? '' : element.description
			});
			
			switch (element.xtype) {
				case 'datefield':
					element = Ext.applyIf({
						format			: MODx.config.manager_date_format,
						startDay		: parseInt(MODx.config.manager_week_start),
						minValue	 	: element.extra.minDateValue,
						maxValue 		: element.extra.maxDateValue
					}, element);
					
					break;
				case 'timefield':	
					element = Ext.applyIf({
						format			: MODx.config.manager_time_format,
						offset_time		: MODx.config.server_offset_time,
						minValue 		: element.extra.minTimeValue,
						maxValue 		: element.extra.maxTimeValue
					}, element);
					
					break;
				case 'datetimefield':	
					element = Ext.applyIf({
						xtype 			: 'xdatetime',
						dateFormat		: MODx.config.manager_date_format,
						timeFormat		: MODx.config.manager_time_format,
						startDay		: parseInt(MODx.config.manager_week_start),
						offset_time		: MODx.config.server_offset_time,
						minDateValue 	: element.extra.minDateValue,
						maxDateValue 	: element.extra.maxDateValue,
						minTimeValue 	: element.extra.minTimeValue,
						maxTimeValue 	: element.extra.maxTimeValue
					}, element);
					
					break;
				case 'passwordfield':
					element = Ext.applyIf({
						xtype 			: 'textfield',
						inputType		: 'password'
					}, element);
					
					break;
				case 'richtext':
					element = Ext.applyIf({
						xtype			: 'textarea',
						listeners		: {
							'afterrender' : {
								fn 			: function() {
									if (MODx.loadRTE) {
										MODx.loadRTE(this.id, {
											toolbar1 				: this.extra.toolbar1 || 'undo redo | bold italic underline strikethrough | styleselect bullist numlist outdent indent',
											toolbar2 				: this.extra.toolbar2 || '',
											toolbar3 				: this.extra.toolbar3 || '',
											plugins 				: this.extra.plugins || '',
											menubar 				: false,
											statusbar				: false,
											height					: '150px',
											toggle					: false
										});
									}
								},
								scope 		: element
							}
						}
					}, element);
					
					break;
				case 'boolean':
	 				element = Ext.applyIf({
						xtype			: 'combo-boolean'
					}, element);
					
					break;	
				case 'combo':
					elements.push({
						xtype	: 'hidden',
						name	: element.name + '-replace',
						id		: element.id + '-replace'
					});
					
					element = Ext.applyIf({
						xtype			: 'modx-combo',
					   	store			: new Ext.data.JsonStore({
							fields			: ['value', 'label'],
							data			: element.extra.values || []
						}),
						mode 			: 'local',
						hiddenName		: element.name,
						valueField		: 'value',
						displayField	: 'label',
						listeners		: {
							'select'	: function(data) {
								Ext.getCmp(this.config.id + '-replace').setValue(data.lastSelectionText);
							}
						}
					}, element);
					
					break;
				case 'checkbox':
					element = Ext.applyIf({
						fieldLabel 	: '',
						boxLabel	: element.description,
						inputValue	: 1
					}, element);
					
					break;
				case 'checkboxgroup':
					var items = [];
	
					for (var ii = 0; ii < element.extra.values.length; ii++) {
						items.push({
							name 		: element.name,
							boxLabel	: element.extra.values[ii].label,
							inputValue	: element.extra.values[ii].value
						});
					}
					
					element = Ext.applyIf({
						xtype			: 'checkboxgroup',
					   	columns			: 1,
					   	items			: items
					}, element);
					
					break;
				case 'radiogroup':
					var items = [];
	
					for (var ii = 0; ii < element.extra.values.length; ii++) {
						items.push({
							name 		: element.name,
							boxLabel	: element.extra.values[ii].label,
							inputValue	: element.extra.values[ii].value
						});
					}
					
					element = Ext.applyIf({
						xtype			: 'radiogroup',
					   	columns			: 1,
					   	items			: items
					}, element);
					
					break;
				case 'resource':
					elements.push({
						xtype	: 'hidden',
						name	: element.name,
						id		: element.id + '-replace'
					});

					element = Ext.applyIf({
						xtype		: 'modx-field-parent-change',
						name		: element.name + '-replace',
						formpanel	: 'customtvs-' + config.tvid + '-update-form-panel',
						parentcmp	: element.id + '-replace',
						contextcmp	: null,
						currentid	: 0,
					}, element);
					
					break;
				case 'browser':
					elements.push({
						xtype	: 'hidden',
						name	: element.name,
						id		: element.id + '-replace'
					});
						
					element = Ext.applyIf({
						xtype		: 'modx-combo-browser',
						name		: element.name + '-replace',
						source		: element.extra.source || MODx.config.default_media_source,
						openTo		: element.extra.openTo || '/',
						allowedFileTypes : element.extra.allowedFileTypes || '',
						listeners	: {
							'select'	: {
								fn			: function(data) {
									Ext.getCmp(this.config.id + '-replace').setValue(data.fullRelativeUrl);
								}
							}
						}
					}, element);
					
					break;
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
	
Ext.reg('customtvs-window-item-update', CustomTVs.window.GridTVUpdateItem);