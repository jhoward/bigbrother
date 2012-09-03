
// include headers here

configuration ComponentC {
  provides interface Component;
}

implementation {
  components ComponentP as App;
  // add any needed components here

  Component = App;
  // wire interfaces used by component to their components
}


