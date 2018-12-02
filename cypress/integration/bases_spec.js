describe("Verify 49 images loaded in light atom",()=> {
  let baseUrl = [Cypress.env('VIEWER_URL'),  Cypress.env('DEMO_STONE'), '/', Cypress.env('DEMO_CONFIGURATION')].join('')
it.only('test all light images downloaded',() => {

    cy.visit(baseUrl)
      cy.window().then((win) => {
      var lightImages=  win.ViewerManger.prototype.getViewers().find((atom)=>{
         return   atom.src!==null && atom.src!==undefined && atom.src.indexOf("Dlight")!== -1     
         }).imagesArr

      expect(Object.keys(lightImages)).to.have.lengthOf(49)
      })
  })
})