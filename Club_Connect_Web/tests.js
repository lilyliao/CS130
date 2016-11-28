var selenium = require('selenium-webdriver');

describe('Selenium Tests', function() {

    // Open our Clubconnect website in the browser before each test is run
    beforeEach(function(done) {
        this.driver = new selenium.Builder().
            withCapabilities(selenium.Capabilities.chrome()).
            build();

        this.driver.get('localhost:3000').then(done);
    });

    // Close the web app after each test is run (so that it is opened fresh each time)
    afterEach(function(done) {
        this.driver.quit().then(done);
    });

    // Test to ensure we are on the home page by checking the <h1> tag class attribute
    it('Should be on the home page', function(done) {
        var element = this.driver.findElement(selenium.By.tagName('h1'));

        element.getAttribute('class').then(function(cls) {
            expect(cls).toBe('cover-heading');
            done();
        });
    });

    // Test the sign in button bar by clicking on it, and making sure it takes us to Facebook auth URL
    it('Has a working sign in button', function(done) {
        var element = this.driver.findElement(selenium.By.linkText('Sign in with Facebook'));

        element.click();

        this.driver.getCurrentUrl().then(function(value) {
            expect(value).toContain('/auth/facebook');
            // check after redirect that page has events
            this.driver.wait(until.titleIs('Event List'), 1000).then(function() {
            	var header = this.driver.findElement(selenium.By.tagName('h1'));
            	header.getAttribute('class').then(function(cls) {
            		expect(cls).toBe('cover-heading');
            		done();
            	});
            });
        });
    });
});