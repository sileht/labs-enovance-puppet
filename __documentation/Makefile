#
# Workflow:
#
# inkscape diagram.svg
# make all
# git commit -m 'I this and that'
# git push
#
MODULES=openstack nova keystone swift glance horizon
all:
	for module in ${MODULES} ; do sed -e 's/display:none/display:inline/' < diagram.svg > $$module.svg ; inkscape $$module.svg $$(for other in ${MODULES} ; do if [ $$other != $$module ] ; then echo --select=layer$$other --verb=EditDelete ; fi ; done) --verb=FileSave --verb=FileClose ; done 
