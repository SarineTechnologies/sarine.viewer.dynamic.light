describe('Test Light Atom', () => {

  let events = {
    error: {},
    dataLoaded: {},
    renderAtom: {
      lightReportViewer: {
        first_init_started: Cypress.$.Deferred(),
        first_init_end: Cypress.$.Deferred(),
        full_init_end: Cypress.$.Deferred(),

      }
    }
  }

  let sarineJsonResponse = null;
  let demoUrl = [Cypress.env('DEMO_VIEWER'), 'demo-ondemand.html?', Cypress.env('DEMO_STONE'), '/', Cypress.env('DEMO_CONFIGURATION')].join('')

  before(() => {

    // Load viewer creator demo html page
    cy.visit(demoUrl)
    
    // Register to ViewerCreator events
    cy.document().then((doc) => {
      doc.addEventListener('sarine.error', (e) => {
        events.error = e.detail;
      })

      doc.addEventListener('sarine.data.loaded', (e) => {
        events.dataLoaded = e.detail;
      })

      doc.addEventListener('sarine.render.atom', (e) => {
        let item = e.detail;        
        if (item && events.renderAtom[item.atom][item.status]) {
            events.renderAtom[item.atom][item.status].resolve(item)             
        }
      })
    })
  })
  
 
  describe('Render Light Atom', () => {

    it('check if <sarine-widget atom="lightReportViewer"></sarine> is empty', () => {
      cy.wait(10000)
      cy.get('sarine-widget[atom="lightReportViewer"]').then((el) => {
          expect(el.html()).to.be.empty
      })
    })

    it('render lightReportViewer', () => {
      cy.window().then((win) => {
        win.runRenderOnDemand({atom: 'lightReportViewer'})
      })

    })

    it('checks if <sarine-widget atom="lightReportViewer"></sarine> is contains iframe', () => {
      cy.wait(5000)
      cy.get('sarine-widget[atom="lightReportViewer"]').then((el) => {
        expect(el.find('iframe').length).to.eq(1)
        }).then((el) => {
        // there is access to iframe
        // TODO: inspect iframe 
        console.log('iframe', el.find('iframe')[0].contentWindow);
      })
    })

    it('checks if lightReportViewer iframe contains canvas', () => {
      cy.wait(1000)
      cy.get('sarine-widget[atom="lightReportViewer"] iframe').then((iframe) => {
        expect(iframe.contents().find('canvas').length).to.eq(1)
    })
  })

      it('test first_init_started on lightReportViewer', () => {
        cy.wait(1000)
        Cypress.$.when(events.renderAtom.lightReportViewer.first_init_started).then((item) => {
          expect(item).to.be.an('object').that.is.not.empty
          expect(item.status).to.eq('first_init_started')
        })
      })
      
      it('test first_init_end on lightReportViewer', () => {
        cy.wait(1000)
        Cypress.$.when(events.renderAtom.lightReportViewer.first_init_end).then((item) => {
          expect(item).to.be.an('object').that.is.not.empty
          expect(item.status).to.eq('first_init_end')
        })
      })
  
      it('test full_init_end on lightReportViewer', () => {
        cy.wait(1000)
        Cypress.$.when(events.renderAtom.lightReportViewer.full_init_end).then((item) => {
          expect(item).to.be.an('object').that.is.not.empty
          expect(item.status).to.eq('full_init_end')
        })
      })




  })
})

