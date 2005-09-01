#include "AVEmbeddedLoader.h"
#include <algorithm>
using namespace std;

bool AVEmbeddedLoader::sort_im(OVModule *a, OVModule *b)
{
	int pa = 0, pb = 0;
	m_dict.setDict(a->identifier());
	pa = m_dict.getInteger("priority");
	m_dict.setDict(b->identifier());
	pb = m_dict.getInteger("priority");
	return (pa >= pb);
}

AVEmbeddedLoader::AVEmbeddedLoader()
{
	m_srv = new AVService();
	m_cfg = new AVConfig();
	m_dict = new AVDictionary(m_cfg->getBaseDir());
	m_modlist = AVLoadEverything(m_cfg->getModuleDir(), m_srv);
	sort(m_modlist.begin(), m_modlist.end(), sort_im);
}

AVEmbeddedLoader::~AVEmbeddedLoader()
{
	delete m_srv;
	delete m_cfg;
	delete m_dict;
}

AVService *AVEmbeddedLoader::srv() { return m_srv; }
AVConfig *AVEmbeddedLoader::cfg() { return m_cfg; }
AVDictionary *AVEmbeddedLoader::dict() { return m_dict; }
AVDictionary *AVEmbeddedLoader::dict(const char* d)
{
	m_dict->setDict(d);
	return m_dict;
}
std::vector<OVModule*> &AVEmbeddedLoader::modlist() { return m_modlist; }