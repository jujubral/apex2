@isTest
private class HelloWorldTest {
	
	@isTest static void hello() {
		HelloWorld hello_world = new HelloWorld();
		String password = hello_world.hello();
		system.assertEquals(password, '123456');
	}
	
}
