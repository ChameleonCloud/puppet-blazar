require 'spec_helper'

describe 'blazar::db' do

  shared_examples 'blazar::db' do
    context 'with default parameters' do
      it { is_expected.to contain_oslo__db('blazar_config').with(
        :connection     => 'sqlite:////var/lib/blazar/blazar.sqlite',
        :idle_timeout   => '<SERVICE DEFAULT>',
        :min_pool_size  => '<SERVICE DEFAULT>',
        :db_max_retries => '<SERVICE DEFAULT>',
        :max_pool_size  => '<SERVICE DEFAULT>',
        :max_retries    => '<SERVICE DEFAULT>',
        :retry_interval => '<SERVICE DEFAULT>',
        :max_overflow   => '<SERVICE DEFAULT>',
      )}
    end

    context 'with specific parameters' do
      let :params do
        { :database_connection     => 'mysql+pymysql://blazar:blazar@localhost/blazar',
          :database_idle_timeout   => '3601',
          :database_min_pool_size  => '2',
          :database_db_max_retries => '-1',
          :database_max_retries    => '11',
          :database_retry_interval => '11',
          :database_max_pool_size  => '11',
          :database_max_overflow   => '21',
        }
      end

      it { is_expected.to contain_oslo__db('blazar_config').with(
        :connection     => 'mysql+pymysql://blazar:blazar@localhost/blazar',
        :idle_timeout   => '3601',
        :min_pool_size  => '2',
        :db_max_retries => '-1',
        :max_pool_size  => '11',
        :max_retries    => '11',
        :retry_interval => '11',
        :max_overflow   => '21',
      )}
    end

    context 'with postgresql backend' do
      let :params do
        { :database_connection => 'postgresql://blazar:blazar@localhost/blazar', }
      end

      it 'install the proper backend package' do
        is_expected.to contain_package('python-psycopg2').with(:ensure => 'present')
      end

    end

    context 'with MySQL-python library as backend package' do
      let :params do
        { :database_connection => 'mysql://blazar:blazar@localhost/blazar', }
      end

      it { is_expected.to contain_package('python-mysqldb').with(:ensure => 'present') }
    end

    context 'with incorrect database_connection string' do
      let :params do
        { :database_connection => 'foodb://blazar:blazar@localhost/blazar', }
      end

      it_raises 'a Puppet::Error', /validate_re/
    end

    context 'with incorrect pymysql database_connection string' do
      let :params do
        { :database_connection => 'foo+pymysql://blazar:blazar@localhost/blazar', }
      end

      it_raises 'a Puppet::Error', /validate_re/
    end

  end

  shared_examples_for 'blazar::db on Debian' do
    context 'using pymysql driver' do
      let :params do
        { :database_connection => 'mysql+pymysql://blazar:blazar@localhost/blazar', }
      end

      it 'install the proper backend package' do
        is_expected.to contain_package('python-pymysql').with(
          :ensure => 'present',
          :name   => 'python-pymysql',
          :tag    => 'openstack'
        )
      end
    end
  end

  shared_examples_for 'blazar::db on RedHat' do
    context 'using pymysql driver' do
      let :params do
        { :database_connection => 'mysql+pymysql://blazar:blazar@localhost/blazar', }
      end

      it 'install the proper backend package' do
        is_expected.not_to contain_package('python-pymysql')
      end
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_configures 'blazar::db'
      it_configures "blazar::db on #{facts[:osfamily]}"
    end
  end
end
