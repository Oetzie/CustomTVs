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