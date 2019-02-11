# frozen_string_literal: true

require 'bounty-targets/intigriti'

describe BountyTargets::Intigriti do
  before :all do
    BountyTargets::Intigriti.make_all_methods_public!
  end

  let(:subject) { BountyTargets::Intigriti.new }

  it 'should fetch a list of programs' do
    programs = IO.read('spec/fixtures/intigriti/programs.json')
    stub_request(:get, %r{/api/project}).with(headers: {host: 'api-public.intigriti.com'})
      .to_return(status: 200, body: programs)
    expect(subject.directory_index).to eq(
      [
        {
          id: 'uz%20leuven/mobile%20apps',
          name: 'Nexuzhealth',
          url: 'https://www.intigriti.com/public/project/uz%20leuven/mobile%20apps',
          status: 'open',
          type: 'public'
        },
        {
          id: 'telenet/telenet',
          name: 'Telenet',
          url: 'https://www.intigriti.com/public/project/telenet/telenet',
          status: 'open',
          type: 'responsibleDisclosure'
        }
      ]
    )
  end

  it 'should fetch program scopes' do
    scopes = IO.read('spec/fixtures/intigriti/scopes.json')
    stub_request(:get, %r{/api/project/intigriti/intigriti})
      .with(headers: {host: 'api-public.intigriti.com'}).to_return(status: 200, body: scopes)
    expect(subject.program_scopes(id: 'intigriti/intigriti')).to eq(
      targets: {
        in_scope: [
          {
            target: 'http://*.intigriti.com',
            type: 'web'
          },
          {
            target: 'http://*.intigriti.me',
            type: 'web'
          },
          {
            target: 'http://*.intigriti.io',
            type: 'web'
          }
        ],
        out_of_scope: [
          {
            target: 'http://blog.intigriti.com',
            type: 'web'
          },
          {
            target: 'http://kb.intigriti.com',
            type: 'web'
          },
          {
            target: 'http://autodiscover.intigriti.com',
            type: 'web'
          },
          {
            target: 'http://go.intigriti.com',
            type: 'web'
          },
          {
            target: 'http://mail.intigriti.com',
            type: 'web'
          },
          {
            target: 'http://msoid.intigriti.com',
            type: 'web'
          },
          {
            target: 'http://news.intigriti.com',
            type: 'web'
          },
          {
            target: 'http://sip.intigriti.com',
            type: 'web'
          },
          {
            target: 'http://click.intigriti.com',
            type: 'web'
          },
          {
            target: 'http://researcheruploads.intigriti.com',
            type: 'web'
          }
        ]
      }
    )
  end
end
